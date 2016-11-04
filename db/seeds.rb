# pre-create first admin (to be disabled after first real admin created)
User.create({ :email => 'fake@blah.com', :is_admin => true, :password => 'ChangeMeRightAway1', :password_confirmation => 'ChangeMeRightAway1', }).save()
