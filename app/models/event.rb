# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :text
#  discipline       :string
#  player_type      :integer          not null
#  max_teams        :integer
#  game_mode        :integer          not null
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  startdate        :date
#  enddate          :date
#  deadline         :date
#  gameday_duration :integer
#  owner_id         :integer
#

class Event < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :matches, -> { order 'gameday ASC' }, dependent: :delete_all
  has_and_belongs_to_many :teams
  has_and_belongs_to_many :participants, class_name: 'User'
  has_many :organizers
  has_many :editors, through: :organizers, source: 'user'

  scope :active, -> { where('deadline >= ?', Date.current) }

  validates :name, :discipline, :game_mode, presence: true
  validates :name, :discipline, :game_mode, :player_type, presence: true
  validates :deadline, :startdate, :enddate, presence: true
  validates :max_teams, numericality: { greater_than_or_equal_to: 0 } # this validation will be moved to League.rb once leagues are being created and not general event objects
  validate :end_after_start

  enum player_types: [:single, :team]

  def self.types
    %w(Tournament League)
  end

  def duration
    return if enddate.blank? || startdate.blank?
    enddate - startdate + 1
  end

  def end_after_start
    return if enddate.blank? || startdate.blank?
    if enddate < startdate
      errors.add(:enddate, "must be after startdate.")
    end
  end

  def deadline_has_passed?
    deadline < Date.current
  end

  def single_player?
    player_type == Event.player_types[:single]
  end

  def add_participant(user)
    participants << user
  end

  def remove_participant(user)
    participants.delete(user)
  end

  def has_participant?(user)
    participants.include?(user)
  end

  def can_join?(user)
    single_player? && (not has_participant?(user)) && (not deadline_has_passed?)
  end

  def can_leave?(user)
    single_player? && has_participant?(user)
  end

  def standing_of(team)
    'Gewinner ' + team.id.to_s
  end
end
