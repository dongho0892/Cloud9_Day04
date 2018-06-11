require 'sinatra'
# require 'sinatra/reloader'
require 'nokogiri'
require 'json'
require 'uri'
require 'rest-client'
require 'csv'


get '/' do 
   erb :index
end

get '/webtoon' do
    #내가 받아온 웹툰 데이터를 저장할 배열 생성
    toons = []
    #원툰 데이터를 받아올 url파악 및 요청보내기
    url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
    result = RestClient.get(url)
    #응답으로 온 내용을 배열 형태로 바꾸기
    webtoons = JSON.parse(result)
    puts webtoons
    #해쉬에서 웹툰 리스트에 해당하는 부분 순환하기
    webtoons["data"].each do |toon|
        #웹툰 제목
        title = toon["title"]
        #웹툰 이미지 주소
        image = toon["thumbnailImage2"]["url"]
        #웹툰을 볼 수 있는 주소
        link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}"
        
        toons << {
            "title"=>title,
            "image"=>image,
            "link"=>link
        }
    end
    #필요한 부분을 분리해서 처음만든 배열에 push
    @daum_webtoon = toons.sample(3)
    erb :webtoon
end

get '/check_file' do
 
    unless File.file?('./test.csv')
            toons = []

            url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
            result = RestClient.get(url)
            webtoons = JSON.parse(result)
            webtoons["data"].each do |toon|
            title = toon["title"]
            image = toon["thumbnailImage2"]["url"]
            link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}"
            toons << [title,image,link]
    end
        #CSV 파일을 새로 생성하는 코드
        CSV.open('./test.csv', 'w+') do |row|
            toons.each_with_index do |toon, index|
                row << [index+1, toon[0], toon[1], toon[2]]
            end
        end
        erb :check_file
    else
        #존재하는 CSV 파일을 불러오는 코드
        @webtoons = []
        CSV.open('./test.csv', 'r').each do |row|
         @webtoons << row
        end
        erb :webtoons
    end
end

# get '/board' do
get '/board/:name' do
    puts params[:name]
end
