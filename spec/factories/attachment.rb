FactoryBot.define do
  factory :attachment do
    attachment_category_id {create(:attachment_category).id}
    base64 {'data:image/gif;base64,R0lGODdhAQABAPAAAP8AAAAAACwAAAAAAQABAAACAkQBADs='}
    file_name { 'test-file.jpg' }

    transient do
      attachable { nil }
    end

    attachable_id { attachable.id }
    attachable_type { attachable.class.name }
    

  end
end
