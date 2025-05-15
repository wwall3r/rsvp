-- verifies a session token
select
    u.*
from
    users_tokens ut
inner join 
    users u 
on 
    ut.user_id = u.id
where
    ut.token = $1
    and ut.context = 'session'
    and ut.created_at > now() - interval '3 months'
