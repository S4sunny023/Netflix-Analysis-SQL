-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select type,count(*) as totel_content from netflix group by type;


--2. Find the most common rating for movies and TV shows

select type,rating from(
select type,
rating, count(*), RANK() OVER(Partition By type Order By Count(*) desc)
as ranking from netflix group by 1,2) as t1 where ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)

select title from netflix where type = 'Movie' and  release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix

select unnest(string_to_array(country,',')) as new_country
,count(show_id) as total_content from netflix group by 1 order by 2 desc limit 5;


--5. Identify the longest movie.

select * from netflix where type = 'Movie' and duration = (select max(duration) from netflix);

--6. Find content added in the last 5 years

select *  from netflix 
	where to_date(date_added,'Month DD,YYYY') >= current_date - interval '5 years'


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select title from netflix where director ilike '%Rajiv Chilaka%';


--8. List all TV shows with more than 5 seasons


select * from netflix where type = 'TV Show' and  split_part(duration,' ',1) :: numeric > 5 ;

--9. Count the number of content items in each genre

select unnest(string_to_array(listed_in ,',')) as genre, 
	count(show_id) as total_content from netflix group  by 1;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

select extract(Year from to_date(date_added,'Month DD, YYYY')) AS year,
count(*),
	round(count(*)::numeric/(select count(*) from netflix where country ilike '%India%')::numeric * 100,2)as Avg_content_per_year_india
  from netflix where country ilike '%India%' group by 1;



--11. List all movies that are documentaries


select title from netflix where listed_in ilike '%Documentaries%';


--12. Find all content without a director


select title from netflix where director is null;


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select count(*) from netflix where casts ilike '%Salman Khan%' and release_year > extract(year from current_date) -10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select  unnest(string_to_array(casts,',')) as actors, count(*) as total_content from netflix  where country ilike '%India%' 
	group by 1 order by 2 desc limit 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2



