-- Find a user by email
select
    *
from 
    users
where 
    email = $1
