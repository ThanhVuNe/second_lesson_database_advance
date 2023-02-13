
-- trigger 1: khi thêm địa điểm bắt buộc phải nằm trong 1 quốc gia nào đó, nếu không thì thông báo lỗi
DELIMITER $$
create trigger before_locations_insert
before insert on locations
for each row
begin
	if(not exists(select country_id from countries where country_id=new.country_id))then
		signal sqlstate '45000'
        set message_text='Country not found!! Please check country and insert again';
	end if;
end$$
INSERT INTO `qlns`.`locations` (`street_address`, `postal_code`, `city`, `state_province`, `country_id`) 
VALUES ('469 Ton Duc Thang', '55000', 'Da Nang', 'Da Nang', 'TL');

-- trigger 2: khi sửa một quốc gia thì bắt buộc phải nằm trong một khu vực sẵn có
DELIMITER $$
create trigger before_countries_update
before update on countries
for each row
begin
	if(not exists(select region_id from regions where region_id=new.region_id))then
		signal sqlstate '45000'
        set message_text='Please check region and update again';
	end if;
end$$
UPDATE `qlns`.`countries` SET `region_id` = '6' WHERE (`country_id` = 'ZW');
-- event 1: tạo 1 event trong đó mỗi ngày sẽ vào kiểm tra và xóa các khu vực có tên trùng nhau
create event if not exists delete_duplicate_region_name
on schedule every 1 day
do
	delete r2 from regions r1 join regions r2 where r1.region_id<r2.region_id and r1.region_name=r2.region_name;

-- event 2: tạo 1 event trong đó mỗi tháng sẽ thực hiện kiểm tra và xóa các nhân viên có thâm niên trên 30 năm và có lương thấp nhất
create event if not exists delete_employee_by_hire_date_and_salary
on schedule every 1 month
do
	delete from employees where TIMESTAMPDIFF(year,hire_date, now())>30 order by salary limit 1;
    

    





