require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require "sqlite3"

# Ta bort en frukt

post("/fruits/:id/delete") do 
  # hämta frukten
  id = params[:id].to_i
  # koppla till db
  db = SQLite3::Database.new("db/fruits.db")

  db.execute("DELETE FROM fruits WHERE id = ?",id)
  redirect("/fruits")

end


get ("/") do
  slim (:start)

end

get ("/home") do
  slim (:home)

end

get ("/about") do
  slim (:about)

end

# Lektionsuppgifter

get ("/test") do

end


get('/fruits1:id') do
 fruits = ["Äpple","Banan","Apelsin"]
 id = params[:id].to_i
 @fruit = fruits[id]
 slim(:fruits)
end

get ("/cat") do
@cat = {
  "name" => "sillyCat",
  "age" => "2"
}

  slim(:index1) #ändrade namn pga ny övning som använde sig av slim index
end

get("/cats") do
  @cats = [
  {
    "name" => "sillyCat1",
    "age" => "2"
  },
  {
    "name" => "sillyCat2",
    "age" => "40"
  }
  ]
  slim(:catsList)

end


get("/fruit") do

  slim(:"fruits/new")
 
end

post("/fruit") do
  #hämtar det användaren skrev från formuläret
  newFruitName = params[:fruitName]
  newFruitAmount = params[:num].to_i

  p "Användaren vill ha #{newFruitAmount}st av frukten #{newFruitName}"
    
  #kopplar formuläret till databasen :)
  db = SQLite3::Database.new("db/fruits.db")
  db.execute("INSERT INTO fruits (name, amount) VALUES (?,?)", [newFruitName,newFruitAmount])
  redirect("/fruits") #hoppa till routen som visar upp alla frukter

end

# update/edit
get("/fruits/:id/edit") do
  # koppla till db
  db = SQLite3::Database.new("db/fruits.db")

  db.results_as_hash = true
  id = params[:id].to_i
  @special_frukt = db.execute("SELECT * FROM fruits WHERE id=?",id).first

  # visa formulär för att uppdatera
  slim(:"fruits/edit")
end

post("/fruits/:id/update") do
  #plocka upp id, name, amount
  id = params[:id].to_i
  name = params[:name]
  amount = params[:amount].to_i

  # koppla till db
  db = SQLite3::Database.new("db/fruits.db")
  # samma ordning i array som i det där andra som står under :)
  db.execute("UPDATE fruits SET name=?, amount=? WHERE id=?",[name,amount,id])
  # slutligen, redirecta till fruits som har hand om uppvisning
  redirect("/fruits")
end


get("/fruits") do

  query = params[:q]

  p "Användaren skrev #{query}"


  #Gör en koppling till db(databasen)
  db = SQLite3:: Database.new("db/fruits.db")

  #[{},{},{}] vi önskar oss detta format iställer för [[],[],[]]
  db.results_as_hash = true

  #Hämta allting från db
  @datafrukt = db.execute("SELECT * FROM fruits")

  p @datafrukt


  #sätter detta under db så att sidan har tillgång till den :)
  #om query finns OCH ej är tom,
  if query && !query.empty?
    #hämta det som användaren söker från db,
    @datafrukt = db.execute("SELECT* FROM fruits WHERE name LIKE ?", "%#{query}%")
    else
    #annars hämta allting från db!
    @datafrukt = db.execute ("SELECT * FROM fruits")
  end

  #Visa upp med slim
  slim(:"fruits/index")

end

