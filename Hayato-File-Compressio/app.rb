require 'sinatra'
require 'zip'
require 'erb'  # ERBを読み込む（URLエンコード用）

# ファイルアップロードページ
get '/' do
  erb :index
end

# アップロードされたファイルを処理して圧縮
post '/upload' do
  if params[:file] && params[:file][:filename]
    filename = params[:file][:filename]
    tempfile = params[:file][:tempfile]

    # 圧縮されたファイルを保存するパス
    compressed_file_path = File.join(settings.root, 'compressed_files', "compressed_#{filename}.zip")

    if File.exist?(compressed_file_path)
      raise "File already exists"
    end

    # 圧縮処理
    ::Zip::File.open(compressed_file_path, ::Zip::File::CREATE) do |zipfile|
      zipfile.add(filename, tempfile.path)
    end

    # ダウンロード用リンクを表示 (ファイル名をURLエンコード)
    encoded_filename = ERB::Util.url_encode("compressed_#{filename}.zip")
    "zipに圧縮しました: <a href='/download/#{encoded_filename}'>ダウンロードリンク</a>"
  else
    "No file uploaded"
  end
end

# 圧縮されたファイルのダウンロード
get '/download/:filename' do
  file_path = File.join(settings.root, 'compressed_files', params[:filename])

  if File.exist?(file_path)
    send_file file_path, filename: params[:filename], type: 'application/zip'
  else
    "File not found"
  end
end
