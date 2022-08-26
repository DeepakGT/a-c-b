namespace :attachments do
  desc 'Insert initial records from current registers'
  task fill_attachment_category_id: :environment do
    puts 'Init fill process'

    Attachment.all.group_by(&:category).each do |category,attachments|
      id_cat = AttachmentCategory.find_or_create_by(name:category.downcase).id
      case category.downcase

      when 'lmn'
        attachments.each { |att| att.update(attachment_category_id: id_cat) }
      when 'dx'
        attachments.each { |att| att.update(attachment_category_id: id_cat) }
      when 'dx video'
        attachments.each { |att| att.update(attachment_category_id: id_cat) }
      when 'other'
        attachments.each { |att| att.update(attachment_category_id: id_cat) }
      else
        next
      end
    end

    puts 'End fill process'
    puts 'Create non-existing categories'
    attachment_category_data = [{ name: 'vob' },
                                { name: 'dx' },
                                { name: 'dx video' },
                                { name: 'lmn' },
                                { name: 'dx report' },
                                { name: 'consents' },
                                { name: 'financial agreement' },
                                { name: 'tx plan' },
                                { name: 'insurance' },
                                { name: 'treatment Plan' },
                                { name: 'referral' },
                                { name: 'doctor notes' },
                                { name: 'iep' },
                                { name: 'consent forms' },
                                { name: 'intake forms' },
                                { name: 'parental questionnaire' },
                                { name: 'roi' },
                                { name: 'other' }]

    attachment_category_data.each do |category_data|
      AttachmentCategory.find_or_create_by(category_data)
    end

    puts 'End creation of category data'
  end
end
