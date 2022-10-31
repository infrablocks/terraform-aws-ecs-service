# frozen_string_literal: true

require 'json'
require 'set'

RSpec::Matchers
  .define(
    :a_policy_with_statement
  ) do |expected_statement, options = {}|
  def normalise(statement)
    %i[Resource NotResource Action NotAction]
      .each_with_object(statement) do |section, s|
      s[section] = s[section].to_set if s[section].is_a?(Array)
    end
  end

  match do |actual|
    return false unless actual

    expected_statement = normalise(expected_statement)
    expected_matchers, expected_entries =
      expected_statement
      .partition { |_, v| v.respond_to?(:matches?) }
      .map(&:to_h)

    policy = JSON.parse(actual, symbolize_names: true)

    all_statements = policy[:Statement]

    return false unless all_statements

    candidate_statements = all_statements.filter do |candidate_statement|
      expected_entries <= normalise(candidate_statement)
    end
    matching_statements = candidate_statements.filter do |candidate_statement|
      expected_matchers.all? do |key, matcher|
        matcher.matches?(candidate_statement[key])
      end
    end

    present = !matching_statements.empty?

    if present && options[:without_keys]
      options[:without_keys].each do |key|
        return false if candidate_statements.key?(key)
      end
    end

    present
  end
end
