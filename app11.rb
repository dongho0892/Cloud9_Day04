require 'sinatra'
# require 'sinatra/reloader'
require 'json'
require 'rest-client'
require 'nokogiri'
require 'csv'

get '/' do
    erb :index
end

get '/webtoon' do
    
    # daumurl = RestClient.get(URI.encode("http://comic.naver.com/webtoon/weekday.nhn"))
    # result = Nokokgiri::HTML.parse(daumurl)
    # mon1 = result.css('#content > div.list_area.daily_all > div.col.col_selected > div > ul > li:nth-child(1) > a')
    # puts mon1
    
    # @mon1.text   => 
    
    ################################ 뭐 부터 먼저 해야하는가?
    
    # 내가 받아온 웹툰 데이터를 저장할 배열 생성
    # 웹툰 데이터를 받아올 url 파악 및 요청 보내기
    # 응답으로 온 내용을 해쉬 형태로 바꾸기
    # 해쉬에서 웹툰 리스트에 해당하는 부분 순환하기
    # 필요한 부분을 분리해서 처음 만든 배열에 push 
    
    # jason formatter 설치
    
    
    # 내가 받아온 웹툰 데이터를 저장할 배열 생성
    toons = []
    # 웹툰 데이터를 받아올 url 파악 및 요청 보내기
    url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
    result = RestClient.get(url)
    # 응답으로 온 내용을 해쉬 형태로 바꾸기
    webtoons = JSON.parse(result)
    # 해쉬에서 웹툰 리스트에 해당하는 부분 순환하기
    webtoons["data"].each do |toon|
    # http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon 에서 
        # 웹툰 제목
        title = toon["title"]
        # 웹툰 이미지 주소  
        image = toon["thumbnailImage2"]["url"]  # 썸네일 안에서 url을 뽑아야됨.
        # 웹툰을 볼 수 있는 주소
        link = "http://webtoon.daum.net/webtoon/view#{toon["nickname"]}"
    # 필요한 부분을 분리해서 처음 만든 배열에 push 
        toons << {"title" => title, # title이라는 키의 값(value)은 title 
                "image" => image,
                "link" => link
                }
    end
    
    # 완성된 배열 중에서 3개의 웹툰만 랜덤 추출
    # view에서도 쓸 수 있는 걸 만들어주어야함.
    @daum_webtoon = toons.sample(3)
    erb :webtoon

end

get '/check_file' do
    # 파일이 있는지 없는지 어떻게 파악할까요?
    
#   if CSV.read("./test.csv").nil? 
#    if File.file?("./test.csv")  # 현재 경로에서 csv 파일이 있니?  .nil? 이게 비어있니?

    unless File.file?("./test.csv")
        toons = []
        puts "파일이 없습니다."         # 파일 존재 여부 판단.

            url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
            result = RestClient.get(url)
            webtoons = JSON.parse(result)
            webtoons["data"].each do |toon|
            title = toon["title"]
            image = toon["thumbnailImage2"]["url"]
            link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}"
            toons << [title,image,link]

        # CSV 파일을 새로 생성하는 코드
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

        erb :webtoons
    end
        
end