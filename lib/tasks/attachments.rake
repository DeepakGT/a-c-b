namespace :attachments do
  desc "Insert the ids of the category corresponding to the old data"
  task fill_attachment_category_id: :environment do

    all_attachments_grouped = Attachment.all.group_by(&:category)

    puts 'Init fill process'

    all_attachments_grouped.each do |category,attachments|
      id_cat = AttachmentCategory.find_by(name:category).id
      case category
      when 'LMN'
        attachments.each {|att| att.update(attachment_category_id: id_cat)}
      when 'Dx'
        attachments.each {|att| att.update(attachment_category_id: id_cat)}
      when 'Dx Video'
        attachments.each {|att| att.update(attachment_category_id: id_cat)}
      when 'Other'
        attachments.each {|att| att.update(attachment_category_id: id_cat)}
      else
        next
      end
    end

    puts 'End fill process'

  end

end
