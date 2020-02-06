module Spree
  module ReportsControllerDecorator

    def sales_by_store
      params[:q] = {} unless params[:q]

      params[:q][:completed_at_gt] = if params[:q][:completed_at_gt].blank?
                                       Time.zone.now.beginning_of_month
                                     else
                                       begin
                                         Time.zone.parse(params[:q][:completed_at_gt]).beginning_of_day
                                       rescue StandardError
                                         Time.zone.now.beginning_of_month
                                       end
                                     end

      if params[:q] && !params[:q][:completed_at_lt].blank?
        params[:q][:completed_at_lt] = begin
                                         Time.zone.parse(params[:q][:completed_at_lt]).end_of_day
                                       rescue StandardError
                                         ''
                                       end
      end

      params[:q][:s] ||= 'completed_at desc'

      @search = Order.complete.ransack(params[:q])
      @orders = @search.result

      @totals = {}
      @orders.each do |order|
          @totals[order.store.name] = { item_total: ::Money.new(0, order.currency), adjustment_total: ::Money.new(0, order.currency), sales_total: ::Money.new(0, order.currency) } unless @totals[order.currency]
          @totals[order.store.name][:item_total] += order.display_item_total.money
          @totals[order.store.name][:adjustment_total] += order.display_adjustment_total.money
          @totals[order.store.name][:sales_total] += order.display_total.money
      end
    end


  end
end

::Spree::Admin::ReportsController.add_available_report!(:sales_by_store)
::Spree::Admin::ReportsController.prepend Spree::ReportsControllerDecorator
