-- creates a user
insert into
    users(email, name)
values
    ($1, $2)
returning
    *
