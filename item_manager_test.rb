require_relative "item_manager"
require_relative "item_count"

manager = ItemManager.new

manager.add("test1",0)
manager.add("test1",1)
manager.add("test1",0)
manager.add("test2",1)

manager.print