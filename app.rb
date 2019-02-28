require 'sinatra'
require 'sqlite3'
require 'slim'
require 'byebug'

get ('/') do
    slim(:index)
end 

get('/login/:id') do

    slim(:loginid)
end 

get('/users/login') do 
    slim(:login)
end 

post('/login') do 
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    result = db.execute("SELECT Password, id, Username From users Where Username = (?)", params["username"])

    if params["username"] == result[0]["Username"] 
        if params["password"] == result[0]["Password"]
        redirect('/')
        else
            redirect('/no_access')
        end 
    else
        redirect('/no_access')
    end 
    session[:username] = params["username"]
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
