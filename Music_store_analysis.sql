-- who is the senior most employee
select * from employee
order by title desc
limit 1

-- which country have the most invoices
select * from invoice
select max(billing_country) from invoice

-- top 3 values of total invoices
select total,max(total) from invoice
group by total
order by total desc
limit 3
-- which city has the most invoices
select billing_city,sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1
-- best customer who has spent the most amount
select customer.customer_id,concat(first_name,'',last_name)as name,sum(total)as total from customer
join invoice on invoice.customer_id = customer.customer_id
group by customer.customer_id,name
order by total desc
limit 1

-- return email,name,,genre of all rock music listeners order by email starting from alphabet a
select distinct email,concat(first_name,last_name)as name from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
order by email
-- return the artist name and the total track count of the top10 rock bands
select artist.artist_id,artist.name,count(artist.artist_id)as total from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by total desc
limit 10
-- return the song names that have a name length longer  than the avg name length. return the name for each track and then order by the song length in desc
select name from
(select name,length(name) as name_length,avg(length(name)) over()as avg_length from track
group by name,name_length)track
where name_length>avg_length
order by name_length desc

-- return the track names that have a song length longer  than the avg song length. return the name and the milliseconds for each track and then order by the song length in desc
select name,milliseconds from track
where milliseconds > (select round(avg(milliseconds),0) from track)
order by milliseconds desc

-- how much amount spent by each customer on artist. return customer name, artist name and total spent
select concat(customer.first_name,'',customer.last_name) as name,artist.name,sum(invoice_line.quantity*invoice_line.unit_price) as amount_spent from customer 
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by concat(customer.first_name,'',customer.last_name),artist.name
order by amount_spent desc

-- return each country with top genre
select country,name,total_purchases from
(select row_number() over(partition by country) as rnk, country,name,total_purchases from
(select billing_country as country,genre.name as name,count(quantity) as total_purchases from invoice
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id= genre.genre_id
group by country,genre.name
order by country,total_purchases desc)invoice) invoice
where rnk = 1

-- return customer who spent the most from each country
select first_name,last_name,billing_country,total from
(select row_number() over(partition by billing_country order by billing_country,total desc) as rnk,billing_country,first_name,last_name,total from 
(select first_name,last_name,billing_country,sum(total) as total from customer
join invoice on customer.customer_id = invoice.customer_id
group by 1,2,3) customer) customer
where rnk = 1