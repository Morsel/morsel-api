ActiveAdmin.register MorselKeyword do
  actions :index,:new,:edit,:update,:create
  permit_params :name
end
