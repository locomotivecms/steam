require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Pagination do

  include ::Liquid::StandardFilters
  include Locomotive::Steam::Liquid::Filters::Base
  include Locomotive::Steam::Liquid::Filters::Pagination

  it 'returns a navigation block for the pagination' do
    pagination = {
      "previous"   => nil,
      "parts"     => [
        { 'title' => '1', 'is_link' => false },
        { 'title' => '2', 'is_link' => true, 'url' => '/?page=2' },
        { 'title' => '&hellip;', 'is_link' => false, 'hellip_break' => true },
        { 'title' => '5', 'is_link' => true, 'url' => '/?page=5' }
      ],
      "next" => { 'title' => 'next', 'is_link' => true, 'url' => '/?page=2' }
    }
    html = default_pagination(pagination, 'css:flickr_pagination')
    expect(html).to match(/<div class="pagination flickr_pagination">/)
    expect(html).to match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    expect(html).to match(/<a href="\/\?page=2">2<\/a>/)
    expect(html).to match(/<span class=\"gap\">\&hellip;<\/span>/)
    expect(html).to match(/<a href="\/\?page=2" class="next_page">Next &raquo;<\/a>/)

    pagination.merge!({
      'previous' => { 'title' => 'previous', 'is_link' => true, 'url' => '/?page=4' },
      'next'     => nil
    })

    html = default_pagination(pagination, 'css:flickr_pagination')
    expect(html).to_not match(/<span class="disabled prev_page">&laquo; Previous<\/span>/)
    expect(html).to match(/<a href="\/\?page=4" class="prev_page">&laquo; Previous<\/a>/)
    expect(html).to match(/<span class="disabled next_page">Next &raquo;<\/span>/)

    pagination.merge!({ 'parts' => [] })
    html = default_pagination(pagination, 'css:flickr_pagination')
    expect(html).to eq ''
  end

end
