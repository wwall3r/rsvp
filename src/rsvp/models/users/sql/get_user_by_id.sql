-- Find a user by id
select
    *
from 
    users
where 
    id = $1
