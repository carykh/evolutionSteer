interface  ISavable{
  public JSONObject saveToJson();
  
  public void loadFromJson(JSONObject object);
}