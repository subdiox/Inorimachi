import requests
import json
import subprocess

for id in range(100, 400):
  print(f'Trying to retrieve data of inorin video ID: {id}')
  url = f'https://ssl-cache.stream.ne.jp/www50/eqb068jrbh/jmc_pub/eq_meta/v1/{id}.jsonp'
  response = requests.get(url)
  response.encoding = response.apparent_encoding
  if response.status_code == 200:
    result = response.text.replace('metaDataResult(', '').replace(');', '')
    try:
      json_data = json.loads(result)
      title = json_data['movie']['title']
      if title.endswith('公開用.mp4'):
        print(f'Downloading inorin video ID: {id}')
        movie_path = json_data['movie']['movie_list_hls'][0]['url']
        movie_url = json_data['movie']['movie_url_mobile'].split(movie_path.split('/')[0])[0] + movie_path
        subprocess.run(f'youtube-dl {movie_url} -o {title}', shell=True)
    except Exception:
      pass
