module SimpleCalendar
  class WeekTable < WeekCalendar
    def initialize(view_context, opts={})
      opts.reverse_merge!(hour_range: default_hour_range)

      super
    end
    
    def default_hour_range
      { first_hour: '06:00', last_hour: '23:00' }
    end
    
    def render_weeks
      start_hour = @timezone.parse(get_option(:hour_range)[:first_hour])
      end_hour = @timezone.parse(get_option(:hour_range)[:last_hour])
      
      capture do
        date_range.each_slice(7) do |week|
          (start_hour.to_i..end_hour.to_i).step(1.hour) do |hour|
            concat content_tag(:tr, render_week_hour(week, hour), get_option(:tr, week))
          end
        end
      end
    end
    
    def render_week_hour(week, hour)
      results = week.map do |day|
        current_datetime = DateTime.new(day.year, day.month, day.day, Time.at(hour).hour)
        content_tag :td, get_option(:td, start_date, day) do
          block.call(current_datetime, events_for_datetime(current_datetime))
        end
      end
      
      safe_join([content_tag(:th, I18n.l(Time.at(hour), format: :time_only))] + results)
    end
    
    def default_thead
      ->(dates) {
        content_tag(:thead) do
          content_tag(:tr) do
            capture do
              concat content_tag(:th, I18n.t('datetime.prompts.hour'))
              dates.each do |date|
                day_name = I18n.t(options.fetch(:day_names, "date.abbr_day_names"))[date.wday]
                concat content_tag(:th, "#{day_name} #{I18n.l(date)}")
              end
            end
          end
        end
      }
    end
    
    def events_for_datetime(datetime)
      if events.any? && events.first.respond_to?(:simple_calendar_start_time)
        events.select do |e|
          event_time = e.send(:simple_calendar_start_time).in_time_zone(@timezone)
          datetime.to_date == event_time.to_date && datetime.hour == event_time.hour
        end.sort_by(&:simple_calendar_start_time)
      else
        events
      end
    end
  end
end

