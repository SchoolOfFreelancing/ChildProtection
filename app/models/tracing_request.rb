class TracingRequest < CouchRest::Model::Base
  use_database :tracing_request

  include PrimeroModel
  include Primero::CouchRestRailsBackward

  include Record
  include Ownable
  include PhotoUploader
  include AudioUploader
  include Flaggable

  property :tracing_request_id
  property :relation_name
  property :reunited, TrueClass

  after_save :find_match_children

  FORM_NAME = 'tracing_request'

  def initialize *args
    self['photo_keys'] ||= []
    arguments = args.first

    if arguments.is_a?(Hash) && arguments["current_photo_key"]
      self['current_photo_key'] = arguments["current_photo_key"]
      arguments.delete("current_photo_key")
    end

    self['histories'] = []
    super *args
  end

  design do
    view :by_tracing_request_id
    view :by_relation_name,
            :map => "function(doc) {
                if (doc['couchrest-type'] == 'TracingRequest')
               {
                  if (!doc.hasOwnProperty('duplicate') || !doc['duplicate']) {
                    emit(doc['relation_name'], null);
                  }
               }
            }"
  end

  def self.quicksearch_fields
    [
      'tracing_request_id', 'short_id', 'relation_name', 'relation_nickname', 'tracing_names', 'tracing_nicknames',
      'monitor_number', 'survivor_code'
    ]
  end

  def self.form_matchable_fields
    form_fields = FormSection.get_matchable_fields_by_parent_form(FORM_NAME, false)
    Array.new(form_fields).map(&:name)
  end

  def self.subform_matchable_fields
    form_fields = FormSection.get_matchable_fields_by_parent_form(FORM_NAME)
    Array.new(form_fields).map(&:name)
  end

  def self.matchable_fields
    form_matchable_fields.concat(subform_matchable_fields)
  end

  include Searchable #Needs to be after ownable

  searchable do
    form_matchable_fields.each { |field| text field }

    subform_matchable_fields.each do |field|
      text field do
        self.tracing_request_subform_section.map{|fds| fds[:"#{field}"]}.compact if self.try(:tracing_request_subform_section)
      end
    end

  end

  def self.find_by_tracing_request_id(tracing_request_id)
    by_tracing_request_id(:key => tracing_request_id).first
  end

  #TODO: Keep this?
  def self.search_field
    "relation_name"
  end

  def self.view_by_field_list
    ['created_at', 'relation_name']
  end

  def self.minimum_reportable_fields
    {
      'boolean' => ['record_state'],
      'string' => ['inquiry_status', 'owned_by'],
      'multistring' => ['associated_user_names'],
      'date' => ['inquiry_date']
    }
  end

  def tracing_names
    names = []
    if self.tracing_request_subform_section.present?
      names = self.tracing_request_subform_section.map(&:name).compact
    end
    return names
  end

  def tracing_nicknames
    names = []
    if self.tracing_request_subform_section.present?
      names = self.tracing_request_subform_section.map(&:name_nickname).compact
    end
    return names
  end

  def fathers_name
    self.relation_name if self.relation_name.present? && self.relation.present? && self.relation.downcase == 'father'
  end

  def mothers_name
    self.relation_name if self.relation_name.present? && self.relation.present? && self.relation.downcase == 'mother'
  end

  def set_instance_id
    self.tracing_request_id ||= self.unique_identifier
  end

  def create_class_specific_fields(fields)
    self['inquiry_date'] ||= DateTime.now.strftime("%d-%b-%Y")
    self['inquiry_status'] ||= "Open"
  end

  def find_match_children
    match_class = Child
    self.tracing_request_subform_section.each do |tr|
      match_criteria = match_criteria(tr)
      results = self.class.find_match_records(match_criteria, match_class)
      PotentialMatch.update_matches_for_tracing_request(self.id, tr.unique_id, results)
    end
  end
end
