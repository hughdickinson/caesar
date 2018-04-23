FactoryGirl.define do
  factory :extractor do
    workflow nil
    key { generate(:key) }
    config { {} }
    minimum_workflow_version nil

    factory :survey_extractor, class: Extractors::SurveyExtractor
    factory :external_extractor, class: Extractors::ExternalExtractor
  end
end
