require 'sinatra'
require 'sqlite3'
require 'slim'
require 'byebug'
enable:sessions

get ('/') do
    slim(:index)
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
    slim(:post_all, locals:{post: result})
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

post ('/create') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    db.execute("INSERT INTO user_data (Name, Password, Email) VALUES (?,?,?)",params["name"],params["Password"],params["email"])
    redirect('/users')
end 

#result = db.execute("select users.Username, post.Postid, post.Number, post.Text from users INNER JOIN post on users.Id = post.Postid WHERE users.Id = ?", session[:Id])