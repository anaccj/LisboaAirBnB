-- Data description:
-- This analysis was conducted on a dataset of Airbnb listings in the city of Lisbon, Portugal, collected from Inside Airbnb. The data refers up until 19 March,2023, but was retrieved for analysis in April 2023. 
-- The dataset contains information about the hosts, the properties, and the availability of the listings. The analysis aims to provide insights into the pricing, availability, and distribution of Airbnb listings in Lisbon.


-- Finding the listings that are most probable to be available
SELECT id, name, host_id, host_name, neighbourhood_group, neighbourhood, latitude, longitude, room_type, price, availability_365
FROM listings
WHERE availability_365 <> 0;

-- Finding the most common types of rooms in the Lisboa district
SELECT room_type, 
	   COUNT(room_type) AS count_room_type,
	   COUNT(room_type) * 100.0 / SUM(COUNT(room_type)) OVER() AS perc_room_type
FROM listings
WHERE availability_365 <> 0
GROUP BY room_type
ORDER BY count_room_type DESC;

-- Finding what are the neighbourhood groups in the district with more listings
SELECT neighbourhood_group, 
	   COUNT(neighbourhood_group) AS count_neighbourhood_group
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
GROUP BY neighbourhood_group
ORDER BY count_neighbourhood_group DESC;

-- What is the average price per night for each neighbourhood group in the district
SELECT neighbourhood_group, 
	   AVG(price) AS avg_price_neighbourhood_group
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
GROUP BY neighbourhood_group
ORDER BY avg_price_neighbourhood_group DESC;

-- What are the top 10 most expensive listings, and where they are located
SELECT TOP 10 id,
	   name,
	   price,
	   room_type,
	   neighbourhood_group,
	   neighbourhood
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
GROUP BY id,
	     name,
		 price,
		 room_type,
		 neighbourhood_group,
		 neighbourhood
ORDER BY price DESC;

-- What is the average price per night for each room type in the district
SELECT room_type, 
	   AVG(price) AS avg_price_room_type
FROM listings
WHERE availability_365 <> 0 
GROUP BY room_type
ORDER BY avg_price_room_type DESC;

-- What is the average price per night for each room type by neighbourhood group in the district
SELECT neighbourhood_group,
	   room_type, 
	   AVG(price) AS avg_price
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
GROUP BY neighbourhood_group,
		 room_type
ORDER BY neighbourhood_group ASC,
		 avg_price DESC;

-- Finding the neighbourhoods from the city of Lisboa with the most listings
SELECT neighbourhood, 
	   COUNT(neighbourhood) AS count_neighbourhood
FROM listings
WHERE availability_365 <> 0 AND
	  neighbourhood_group = 'Lisboa' AND 
	  room_type <> 'Hotel room'
GROUP BY neighbourhood
ORDER BY count_neighbourhood DESC;

-- Finding the most expensive neighbourhoods to stay in Lisboa
SELECT neighbourhood, 
	   AVG(price) AS avg_price_LISnbhds
FROM listings
WHERE availability_365 <> 0 AND
	  neighbourhood_group = 'Lisboa' AND 
	  room_type <> 'Hotel room'
GROUP BY neighbourhood
ORDER BY avg_price_LISnbhds DESC;

-- What is the distribution of listings by hosts in the whole district
SELECT host_id,
	   host_name,
	   COUNT(host_id) AS count_host_listings
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
GROUP BY host_id,
		 host_name
ORDER BY count_host_listings DESC;

-- Average price/night for the top 5 hosts with the most listings
SELECT TOP 5 host_id,
	   host_name,
	   COUNT(host_id) AS count_host_listings,
	   AVG(price) AS avg_price_host
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
GROUP BY host_id,
		 host_name
ORDER BY count_host_listings DESC;

-- Looking at the listings of the host with the most listings
SELECT *
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
  AND host_id = (SELECT TOP 1 host_id
                 FROM listings
                 WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
                 GROUP BY host_id
                 ORDER BY COUNT(*) DESC);

-- Calculating the projected yearly revenue for the top 5 earning hosts, assuming that the days not available are the days booked and no cancellations occur
SELECT TOP 5 host_id, 
       host_name,
	   COUNT(host_id) AS count_host_listings,
	   AVG(price) AS avg_price_host,
       SUM((365 - availability_365) * price) AS yearly_revenue
FROM listings
WHERE availability_365 <> 0 AND room_type <> 'Hotel room'
GROUP BY host_id, host_name
ORDER BY yearly_revenue DESC;
