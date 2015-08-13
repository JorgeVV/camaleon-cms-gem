=begin
  Camaleon CMS is a content management system
  Copyright (C) 2015 by Owen Peredo Diaz
  Email: owenperedo@gmail.com
  This program is free software: you can redistribute it and/or modify   it under the terms of the GNU Affero General Public License as  published by the Free Software Foundation, either version 3 of the  License, or (at your option) any later version.
  This program is distributed in the hope that it will be useful,  but WITHOUT ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the  GNU Affero General Public License (GPLv3) for more details.
=end
#encoding: utf-8
module Admin::CategoryHelper

  def category_get_options_html(categories, level = 0)
    options = []
    categories.all.decorate.each do |category|
      options << [("—"*level) + category.the_title, category.id] unless @category.id == category.id
      children = category.children
      options += category_get_options_html(children, level + 1) if children.size > 0
    end
    options
  end

end