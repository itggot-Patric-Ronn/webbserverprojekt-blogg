require 'sinatra'
require 'sqlite3'
require 'slim'
require 'byebug'
enable:sessions

get('/') do
    slim(:index)
end 

get('/post/new') do
    if session[:loggedin] == true
        slim(:post_new)
    else
        redirect('/not_loggin')
    end 
end

get('/not_loggin') do 
    slim(:not_loggin)
end 

get('/login/:id') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    id = session[0][:Id]
    result = db.execute("SELECT Password, Id, Mail, Username From users Where Id = (?)", session[0][:Id])
    slim(:loginid, locals:{users:result})
end 

get('/profile/:id/edit') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    result = db.execute("SELECT Password, Id, Mail, Username From users Where Id = (?)", session[:Id])
    slim(:profile_edit, locals:{users: result})
end

post('/profile/:id/uptate') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.execute("UPDATE users SET Username = ?, Mail = ? WHERE Id = ?",params["Username"],params["Mail"], session[:Id])
    redirect("/profile/#{session[:Id]}")
end

get('/post/all') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    result = db.execute("select users.Username, post.Postid, post.Number, post.Text from post INNER JOIN users on users.Id = post.Postid")
    slim(:post_all, locals:{posts: result})
end  

post('/post/:number/edit') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.execute("UPDATE post SET Text = ? WHERE Number = ?",params["text"],params["number"])
    redirect("/post/#{session[:Postid]}")
end 

get('/post/:number/edit') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    number = params["number"]
    p number
    result = db.execute("SELECT Text, Number From post Where Number = (?)", number)
    slim(:post_edit, locals:{users: result})
end

get('/post/:postid') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    session[:Postid] = params["postid"]
    postid = params["postid"]
    result = db.execute("select users.Username, post.Postid, post.Number, post.Text from users INNER JOIN post on users.Id = post.Postid WHERE users.Id = ?", postid)    
    slim(:post_one, locals:{posts: result})
end 

get('/users/login') do 
    slim(:login)
end 

get('/profile/:id') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    id = session[:Id]
    result = db.execute("SELECT Password, Id, Mail, Username From users Where Id = (?)", session[:Id])
    slim(:profile, locals:{users:result})
end 

post('/login') do 
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    result = db.execute("SELECT Password, Id, Mail, Username From users Where Username = (?)", params["username"])
    if params["username"] == result[0]["Username"] 
        if params["password"] == result[0]["Password"]
            session[:username] = result[0]["Username"]
            email = result[0]["Mail"]
            session[:cookies] = request.cookies
            session[:Id] = result[0]["Id"]
            session[:loggedin] = true
            redirect("/profile/#{result[0]["Id"]}")
        else
            redirect('/no_access')
        end 
    else
        redirect('/no_access')
    end 
end

get('/no_access') do 
    slim(:no_access)
end 

get('/users/new') do
    slim(:create_user)
end

post('/create') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    db.execute("INSERT INTO user_data (Name, Password, Email) VALUES (?,?,?)",params["name"],params["Password"],params["email"])
    redirect('/users')
end

post('/post/new') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    postid = session[:Id]
    text = params["text"]
    db.execute("INSERT INTO post (Postid, Text) VALUES (?,?)", postid, text)
    redirect('/post/all')
end

post('/post/:number/delete') do
    db = SQLite3::Database.new("db/dbsave.db")
    number = params["number"]
    db.execute("DELETE FROM post WHERE Number = ?", number)
    redirect('/post/all')
end

post('/profile/:id/delete') do
    db = SQLite3::Database.new("db/dbsave.db")
    Id = params["id"]
    db.execute("DELETE FROM user WHERE Id = ?", Id)
    redirect('/')
end