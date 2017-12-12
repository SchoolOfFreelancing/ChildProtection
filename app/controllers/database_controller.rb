class DatabaseController < ApplicationController

  def delete_children
    if Rails.env.android?
      Child.all.each do |child|
        child.destroy
      end
      render plain: t("data_base.delete_all_documents")
    else
      render plain: t("data_base.operation_not_allowed", :rails_env => Rails.env)
    end

  end

end