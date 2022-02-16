FactoryBot.define do
  factory :attachment do
    category {'image'}
    base64 {'data:image/gif;base64,R0lGODdhAQABAPAAAP8AAAAAACwAAAAAAQABAAACAkQBADs='}
    file_name { 'test-file.jpg' }
  end
end