*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections
Library           BuiltIn

*** Variables ***
${SearchQuery}    The Shawshank Redemption
${FirstMovie}     The Shawshank Redemption
${TypeFilm}       Action
${StartDate}      2010
${EndDate}        2020

*** Test Cases ***
Scenario 1: Verify user can search for a movie on the IMDb homepage
    Open Browser    https://www.imdb.com/    Chrome
    Input text    name=q    ${SearchQuery}
    Maximize Browser Window
    Click Button    id=suggestion-search-button
    Wait Until Page Contains Element    XPath=//*[@id="__next"]/main/div[2]/div[3]/section/div/div[1]/section[1]
    ${FirstSearchShouldBe}=    Get Text    XPath=//*[@id="__next"]/main/div[2]/div[3]/section/div/div[1]/section[2]/div[2]/ul/li[1]/div[2]/div/a    #hence we get result of search
    ${FirstSearchShouldBeWithoutSpace}    Replace String    ${FirstSearchShouldBe}    ${SPACE}    ${EMPTY}    #remove space from result of search because may
    ${SearchQueryWithoutSpace}    Replace String    ${SearchQuery}    ${SPACE}    ${EMPTY}    #remove spaces from input of search query
    BuiltIn.Should Be Equal As Strings    ${FirstSearchShouldBeWithoutSpace}    ${SearchQueryWithoutSpace}
    Close Browser

Scenario 2: Verify user can access the top-rated movies section
    Open Browser    https://www.imdb.com/    Chrome
    Maximize Browser Window
    Click Element    id=imdbHeader-navDrawerOpen
    Sleep    3
    Click Link    xpath=//*[@id="imdbHeader"]/div[2]/aside/div/div[2]/div/div[1]/span/div/div/ul/a[2]
    Wait Until Page Contains Element    xpath=//*[@id="main"]/div/span/div/div/h1
    ${count}=    Get Element Count    class:titleColumn
    Should Be Equal As Numbers    ${count}    250
    ${FirstShouldbe}=    Get Text    //*[@id="main"]/div/span/div/div/div[3]/table/tbody/tr[1]/td[2]/a
    Should Be Equal    ${FirstShouldbe}    ${FirstMovie}
    Close Browser

Scenario3: Verify user can search for movies released in a specific year on IMDb
    Open Browser    https://www.imdb.com/    Chrome
    Maximize Browser Window
    Click Element    XPath=//*[@id="nav-search-form"]/div[1]/div
    Click Element    XPath=//*[@id="navbar-search-category-select-contents"]/ul/a
    Click Element    XPath=//*[@id="main"]/div[2]/div[1]/a
    Select Checkbox    id=title_type-1    #Select Type Film
    Select Checkbox    id=genres-1    #Select type Genre Film
    Input Text    name=release_date-min    ${StartDate}    #start Data Filed
    Input Text    name=release_date-max    ${EndDate}    #End Data Filed
    Click Button    XPath=//*[@id="main"]/p[3]/button    #click Button Search
    Wait Until Page Contains Element    css=.lister-list
    Click Element    xpath=//*[@id="main"]/div/div[2]/a[3]    #click sorted by using user rate
    #From hecne to Line 25 we check if list of film sorting by user rate or no
    ${RatesFilms} =    Get WebElements    css=.inline-block.ratings-imdb-rating
    ${OriginalRates}=    Create List
    FOR    ${Rate}    IN    @{RatesFilms}
        ${_Rate}=    Get Text    ${Rate}
        ${_Rate}=    convert to number    ${_Rate.strip('$')}
        Append To List    ${OriginalRates}    ${_Rate}
    END
    ${copied_Rates} =    Copy List    ${OriginalRates}
    Sort List    ${copied_Rates}
    reverse list    ${copied_Rates}    #why hence we do reverse list ? because in previous step we sorted list ascendingly and we need sort list descendingly
    Lists Should Be Equal    ${copied_Rates}    ${OriginalRates}
    #Ending check if list of films are sorting by user rate or no
    #From hence until line 32 we check all films is Action Film
    ${TypesOfFilms} =    Get WebElements    css=.genre
    FOR    ${Film}    IN    @{TypesOfFilms}
        ${_Film}=    Get Text    ${Film}
        Should Contain    ${_Film}    ${TypeFilm}
    END
    #Ending Check all films is Action Film
    #From hence until line 42 we check all film is feature film
    ${durations_films} =    Get WebElements    css=.text-muted .runtime
    FOR    ${duration_film}    IN    @{durations_films}
        ${_duration_film}=    Get Text    ${duration_film}
        ${_duration_film_without_any_character}=    Get Substring    ${_duration_film}    0    3
        ${_duration_film_without_spaces}=    Replace String    ${_duration_film_without_any_character}    ${SPACE}    ${EMPTY}
        ${_duration_film_without_spaces}=    convert to number    ${_duration_film_without_spaces.strip('$')}
        Should Be True    ${_duration_film_without_spaces} >= 1
    END
    #Ending check all film is feature film or no
    Sleep    1
    Close Browser
