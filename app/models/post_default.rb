=begin
  Camaleon CMS is a content management system
  Copyright (C) 2015 by Owen Peredo Diaz
  Email: owenperedo@gmail.com
  This program is free software: you can redistribute it and/or modify   it under the terms of the GNU Affero General Public License as  published by the Free Software Foundation, either version 3 of the  License, or (at your option) any later version.
  This program is distributed in the hope that it will be useful,  but WITHOUT ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the  GNU Affero General Public License (GPLv3) for more details.
=end
class PostDefault < ActiveRecord::Base
  include Metas
  include CustomFieldsRead
  self.table_name = "posts"

  #extend FriendlyId
  attr_accessible :user_id, :title, :slug, :content, :content_filtered, :status,  :visibility, :visibility_value, :post_order,
                  :post_type_key, :comment_count, :published_at, :post_parent
  attr_accessor :draft_id


  has_many :term_relationships, class_name: "TermRelationship", foreign_key: :objectid, dependent: :destroy, primary_key: :id  #, :autosave => true
  has_many :parent_taxonomy, foreign_key: :term_taxonomy_id, class_name: "TermTaxonomy", through: :term_relationships, :source => :term_taxonomies
  has_many :children, class_name: "PostDefault", foreign_key: :post_parent, dependent: :destroy, primary_key: :id

  validates :title,:slug, presence: true

  # relations

  # callbacks
  before_validation :before_validating
  before_save :before_saved
  before_destroy :destroy_dependencies

  def self.find_by_slug(slug)
    self.where("posts.slug = ? OR posts.slug LIKE ? ", slug, "%-->#{slug}<!--%").reorder("").first
  end

  def parent
    Post.where(id: self.post_parent).first()
  end


  def author
    begin
      User.find(self.user_id)
    rescue
      User.admin_scope.first
    end
  end

  def term_taxonomies
    TermTaxonomy.where("id IN (?)",self.term_relationships.pluck(:term_taxonomy_id))
  end

  def set_meta_from_form(data_metas)
    data_metas.each do |key, value|
      self.set_meta(key, value)
    end
  end

  def in_nav_menu_items
    NavMenuItem.joins(:metas).where("value LIKE ?","%\"object_id\":\"#{self.id}\"%").where("value LIKE ?","%\"type\":\"post\"%").readonly(false)
  end

  private

  def before_validating
    #self.slug = self.title if self.slug.blank?
    #self.slug = self.slug.to_s.parameterize
  end
  def before_saved
    self.content_filtered = content.to_s.include?('<!--:-->') ? content.translations.inject({}) { |h, (key, value)| h[key] = value.squish.strip_tags; h }.to_translate : content.to_s.squish.strip_tags
  end

  def destroy_dependencies
    in_nav_menu_items.destroy_all
  end

end
