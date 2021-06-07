# # exports an individual survey into content manager
# class ContentManagerExporter
#   include Rails.application.routes.url_helpers

#   def initialize(survey_id:)
#     @survey_id = survey_id
#   end

#   def call
#     @survey = Survey.find(@survey_id)
#     raise "survey not found" if @survey.blank?
#     raise "already exported - uri #{@survey.cm_uri}" if @survey.cm_uri.present?
#     raise "questionnaire classification not defined" if @survey.questionnaire.classification.blank?

#     # add the new survey.pdf
#     files = []
#     filename_pdf = generate_pdf
#     files << {
#       title: @survey.application_id + " " + @survey.name,
#       filename: filename_pdf
#     }

#     # add the attachments from the survey answers
#     title_for_answer_documents = ->(answer, i) {
#       @survey.application_id + " " + (answer.question.system_id || answer.question.prompt || '') + " (attachment #{i+1})"
#     }
#     files += gather_documents(answers_with_documents, title_for_answer_documents)

#     # # add the attachments from the survey comments
#     title_for_survey_comment_documents = ->(comment, i) {
#       @survey.application_id + " (attachment #{i+1}) to comment to #{comment.recipient} from #{comment.user.name} on #{comment.created_at.strftime('%m/%d/%Y')} '#{comment.message[0..32]}...'"
#     }
#     files += gather_documents(comments_with_documents(@survey), title_for_survey_comment_documents)

#     # add the attachments from the review checkpoint comments
#     title_for_review_checkpoint_documents = ->(comment, i) {
#       @survey.application_id + " (attachment #{i+1}) to review checkpoint '#{comment.commentable.name}' comment to #{comment.recipient} from #{comment.user.name} on #{comment.created_at.strftime('%m/%d/%Y')} '#{comment.message[0..32]}...'"
#     }
#     files += gather_documents(checkpoint_comments_with_documents(@survey), title_for_review_checkpoint_documents)

#     # add the attachments from the review comments
#     title_for_review_comment_documents = ->(comment, i) {
#       @survey.application_id + " (attachment #{i+1}) to review comment to #{comment.recipient} from #{comment.user.name} on #{comment.created_at.strftime('%m/%d/%Y')} '#{comment.message[0..32]}...'"
#     }
#     files += gather_documents(comments_with_documents(@survey.review), title_for_review_comment_documents)
    

#     # send to cm ------------------------

#     cm = ContentManager.new

#     # find or create the KPB Box record -- division + questionnaire, and save the uri
#     box_cm_uri = @survey.questionnaire.cm_uri
#     if box_cm_uri.blank?
#       results = cm.create_kpb_box(title: @survey.questionnaire.title)  # TODO! need to handle failures
#       box_cm_uri = results['Results'].first['Uri']
#       if box_cm_uri.present?
#         @survey.questionnaire.update_columns(cm_uri: box_cm_uri)
#       end
#     end
#     raise "Unable to create content manager box for #{@survey.application_id}" if box_cm_uri.blank?

#     # find or create the KPB File record -- survey instance, and save the uri
#     file_cm_uri = @survey.cm_uri
#     if file_cm_uri.blank? && box_cm_uri.present?
#       results = cm.create_kpb_file(title: @survey.application_id + " " + @survey.name, container: box_cm_uri, classification: @survey.questionnaire.classification) # TODO! need to handle failures
#       file_cm_uri = results['Results'].first['Uri']
#       if file_cm_uri.present?
#         @survey.update_columns(cm_uri: file_cm_uri)
#       end
#     end
#     raise "Unable to create content manager file for #{@survey.application_id}" if file_cm_uri.blank?

#     # create KPB Documents for all of the attachments/files

#     files.each do |file|
#       #puts "======>>>>>   sending to cm:  #{file[:title]}, #{file[:filename]}"
#       results = cm.create_kpb_document(title: file[:title], container: file_cm_uri, file_content: File.open(file[:filename]).read, file_name: File.basename(file[:filename]))
#       record_cm_uri = results['Results'].first['Uri']
#       if record_cm_uri.blank?
#         raise "Unable to create content manager document for #{@survey.application_id} - #{file[:title]}: #{results}"
#       end
#       # puts "KPB Document Record Uri #{record_cm_uri}"
#     end

#     # cleanup all these tmp files
#     cleanup_files(files.map { |file| file[:filename] })
#   end



#   private

#   def answers_with_documents
#     @survey.answers.select { |answer| answer.documents.attached? }
#   end

#   def comments_with_documents(owner)
#     owner.comments.select { |comment| comment.documents.attached? }
#   end

#   def checkpoint_comments_with_documents(survey)
#     collection = []
#     survey.checkpoint_answers.each do |answer|
#       collection << comments_with_documents(answer)
#     end
#     collection.flatten.compact
#   end

#   def cleanup_files files
#     FileRemover.set(wait: 10.minutes).perform_later(files)
#   end

#   def gather_documents(collection, title_lambda)
#     files = []
#     collection.each do |item|
#       item.documents.each_with_index do |document, i|
#         filename = export_attachment(document)
#         files << {
#           title: title_lambda.call(item, i),
#           filename: filename
#         }
#       end
#     end
#     files
#   end

#   def generate_pdf
#     return if @survey.blank?

#     print_pdf_token = Rails.application.credentials.print_pdf_token
#     print_survey_url = print_survey_url(@survey_id, token: print_pdf_token)
#     puts "--- #{print_survey_url} ---"

#     ticket = SecureRandom.uuid
#     file = Tempfile.new(ticket)
#     file.close
#     filename_pdf = file.path + '.pdf'
#     File.delete(file)

#     _output = `google-chrome --headless --disable-gpu --print-to-pdf="#{filename_pdf}" #{print_survey_url}`
#     ok = $?.success?
#     raise "unable to generate pdf" unless ok

#     filename_pdf
#   end

#   def default_url_options
#     Rails.application.config.action_mailer.default_url_options
#   end

#   def export_attachment document
#     ticket = SecureRandom.uuid
#     file = Tempfile.new(ticket)
#     file.close
#     filename = file.path + '_'
#     File.delete(file)

#     File.open(filename, 'wb') { |f| f.write(document.download) }
#     filename
#   end

# end