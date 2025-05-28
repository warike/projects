class Entry < ActiveRecord::Base
  belongs_to :startup
  before_destroy :reorder_entries

  def reorder_entries
    (self.is_last?) ? true : self.startup.reorder_entries(self.id)
  end

  def is_last?
    !self.startup.entries.where("show_order > ? ",self.show_order).any?
  end

  def entry_types
    [['Video Entry','Video Entry'],['Blog Entry','Blog Entry']]
  end

  def increment
    self.show_order += 1
  end

  def increment!
    increment
    save!
  end

  def decrement
    self.show_order -= 1
  end

  def decrement!
    decrement
    save!
  end

end


