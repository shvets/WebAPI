
  it 'gets genre' do
    genres = subject.get_genres(page: 1)

    path = genres[:items][0][:path]

    result = subject.get_genre(path: path)

    ap result
  end

  it 'tests pagination' do
    result = subject.get_new_books(page: 1)

    ap result

    pagination = result[:pagination]

    expect(pagination[:has_next]).to eq(true)
    expect(pagination[:has_previous]).to eq(false)
    expect(pagination[:page]).to eq(1)

    result = subject.get_new_books(page: 2)

    ap result

    pagination = result[:pagination]

    expect(pagination[:has_next]).to eq(true)
    expect(pagination[:has_previous]).to eq(true)
    expect(pagination[:page]).to eq(2)
  end

  it 'gets audio tracks' do
    path = "http://audioknigi.club/alekseev-gleb-povesti-i-rasskazy"

    result = subject.get_audio_tracks(path)

    ap result
  end

  it 'tests search' do
    query = 'пратчетт'

    result = subject.search(query)

    ap result
  end

  # it 'tests generation' do
  #   result = subject.generate_authors_list('authors.json')
  #
  #   ap result
  # end

  it "tests grouping" do
    authors = JSON.parse(File.open("authors.json").read)

    authors = subject.group_items_by_letter(authors)

    ap authors
  end

end