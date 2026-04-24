-- phần 1: tạo csdl và tạo bảng

create database de001;
use de001;

-- bảng creator
create table creator(
	creator_id varchar(5) primary key not null,
    creator_name varchar(100) not null ,
    creator_email varchar(100) not null unique,
    creator_phone varchar(15) not null unique,
    creator_platform varchar(50) 
);

-- bảng studio
create table studio(
	studio_id varchar(5) primary key not null,
    studio__name varchar(100) not null,
    studio__location varchar(100) not null,
    hourly_price decimal(10,2) not null,
    studio_status varchar(20) not null
);

-- bảng livesession
create table livesession(
	session_id int primary key not null auto_increment,
    creator_id varchar(5) not null,
    foreign key (creator_id) references creator (creator_id),
    studio_id varchar(5) not null,
    foreign key (studio_id) references studio(studio_id),
    session_date date not null,
    duration_hours int not null
);

-- bảng payment
create table payment(
	payment_id int primary key not null auto_increment,
    session_id  int not null,
    foreign key (session_id) references livesession(session_id),
    payment_method  varchar(20) not null,
    payment_amount decimal(10,2) not null,
    payment_date date not null
);

-- thêm dữ liệu creator
insert into creator(creator_id,creator_name,creator_email,creator_phone,creator_platform)
values
('cr01', 'nguyen van a','a@live.com', '0901111111', 'tiktok'),
('cr02', 'tran thi b','b@live.com', '0902222222', 'youtube'),
('cr03', 'le minh c','c@live.com', '0903333333', 'facebook'),
('cr04', 'pham thi d','d@live.com', '0904444444', 'tiktok'),
('cr05', 'vu hoang e','e@live.com', '0905555555', 'shoppee live');

-- thêm dữ liệu studio
insert into studio(studio_id,studio__name,studio__location,hourly_price,studio_status)
values 
('st01','studio a','ha noi', 20.00 ,'available'),
('st02','studio b','hcm', 25.00 ,'available'),
('st03','studio c','danang', 30.00 ,'booked'),
('st04','studio d','ha noi', 22.00 ,'available'),
('st05','studio e','can tho', 18.00 ,'maintenance');

-- thêm dữ liệu livesession
insert into livesession(session_id,creator_id,studio_id,session_date,duration_hours)
values 
(1, 'cr01', 'st01', '2025-05-01', 3),
(2, 'cr02', 'st02', '2025-05-02', 4),
(3, 'cr03', 'st03', '2025-05-03', 2),
(4, 'cr04', 'st04', '2025-05-04', 5),
(5, 'cr05', 'st05', '2025-05-05', 1);

-- thêm dữ liệu payment
insert into payment(payment_id,session_id,payment_method,payment_amount,payment_date)
values 
(1 ,1 , 'cash' ,60.00, '2025-05-01'),
(2 ,2 , 'cash' ,100.00, '2025-05-02'),
(3 ,3 , 'cash' ,60.00, '2025-05-03'),
(4 ,4 , 'cash' ,110.00, '2025-05-04'),
(5 ,5 , 'cash' ,25.00, '2025-05-05');

-- 3. cập nhật creator_platform của creator cr03 thành "youtube" 
update creator
set creator_platform = 'youtube'
where creator_id = 'cr03';

-- 4. do studio st05 hoạt động trở lại, cập nhật studio_status ='availble' và
-- giảm hourly_price 10% giá
update studio
set studio_status ='availble',
    hourly_price = hourly_price * 0.9
where studio_id = 'st05';

-- 5. xóa các payment_method = 'cash' và payment_date trước ngày 2025-05-03
delete from payment
where payment_method = 'cash'
and payment_date < '2025-05-03';

-- phần 2: truy vấn dữ liệu cơ bản 

-- 6. liệt kê studio có studio_status = 'availble' và hourly_price > 20
select * 
from studio
where studio_status = 'availble'
and hourly_price > 20;

-- 7. lấy thông tin creator (creator_name,creator_phone) có nền tảng là tik tok
select creator_name, creator_phone
from creator
where creator_platform like 'tiktok';

-- 8 hiển thị danh sách studio_id, studio_name, hourly_price sắp xếp theo giá thuê giảm dần
select studio_id, studio__name, hourly_price
from studio
order by hourly_price desc;

-- 9 lấy 3 payment đầu tiên có payment_method = 'credit card'
select *
from payment
where payment_method = 'credit card'
limit 3;

-- 10 . hiển thị danh sách creator_id, creator_name  bỏ qua 2 bản ghi đầu và lấy 2 bản ghi tiếp theo
select creator_id, creator_name
from creator
limit 2 offset 2;

-- phần 3 truy vấn dữ liệu nâng cao 

-- 1. hiển thị danh sách livestream gồm session_id,creator_name , studio_name,duration_hours,payment_amount
select l.session_id, c.creator_name, s.studio__name, l.duration_hours, p.payment_amount
from livesession l
join creator c on l.creator_id = c.creator_id
join studio s on l.studio_id = s.studio_id
join payment p on l.session_id = p.session_id;

-- 2 liệt kê tất cả các studio và số lần được sử dụng (kể cả studio chưa từng được thuê)
select s.studio_id, s.studio__name, count(l.session_id) as total_sessions
from studio s
left join livesession l on s.studio_id = l.studio_id
group by s.studio_id, s.studio__name;

-- 3. tính tổng doanh thu theo từng payment_method
select payment_method, sum(payment_amount) as total_revenue
from payment
group by payment_method;

-- 4. thống kê số session của mỗi creator chỉ hiển thị creator có từ 2 session trở lên
select c.creator_id, c.creator_name, count(l.session_id) as total_sessions
from creator c
join livesession l on c.creator_id = l.creator_id
group by c.creator_id, c.creator_name
having count(l.session_id) >= 2;

-- 5. lấy studio có hourly_price cao hơn mức trung bình của tất cả studio
select *
from studio
where hourly_price > (select avg(hourly_price) from studio);

-- 6 hiển thị creator_name,creator_email của những creator đã từng livetream tại studio b
select distinct c.creator_name, c.creator_email
from creator c
join livesession l on c.creator_id = l.creator_id
join studio s on l.studio_id = s.studio_id
where s.studio__name = 'studio b';

drop database de001;