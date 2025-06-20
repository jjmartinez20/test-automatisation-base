@REQ_HU_0001 @MarvelCharacters
Feature: API que maneja el CRUD de personajes de Marvel

  Background:
    * configure ssl = true
    * configure matchEachEmptyAllowed = true
    * def apiUrl = 'http://bp-se-test-cabcd9b246a5.herokuapp.com/jjmartinez20/api/characters'
    * def body =
    """
    {
      "name": "Iron Man",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    * def itemStructure = read('classpath:data/ItemResponseStructure.json')
    * def arrayStructure = "#[] itemStructure"
    * def errorStructure = {error: "#string"}
    * def characterNotFoundErrorMessage = 'Character not found'

  @id:1 @GetAllCharacters
  Scenario: T-API-HU-0001-CA01 - Obtener la lista completa de personajes de Marvel
    Given url apiUrl
    * def body =
    """
    {
      "name": "Iron Man2",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    And request body
    When method POST
    Then status 201
    * def createdCharacter = response
    Given url apiUrl
    When method GET
    Then status 200
    Then match response == arrayStructure
    Then assert response.length > 0
    Given url apiUrl + '/' + createdCharacter.id
    When method DELETE
    Then status 204

  @id:2 @GetExistingCharacter
  Scenario: T-API-HU-0001-CA02 - Obtener uno de los personajes de Marvel registrados
    Given url apiUrl
    * def body =
    """
    {
      "name": "Iron Man3",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    And request body
    When method POST
    Then status 201
    * def createdCharacter = response
    Given url apiUrl + '/' + createdCharacter.id
    When method GET
    Then status 200
    Then match response == itemStructure
    Given url apiUrl + '/' + createdCharacter.id
    When method DELETE
    Then status 204

  @id:3 @CreateCharacter
  Scenario: T-API-HU-0001-CA03 - Crear un nuevo personaje de Marvel
    Given url apiUrl
    And request body
    When method POST
    Then status 201
    Then match response == itemStructure
    Then assert response.id > 0
    Then assert response.name == body.name
    Then assert response.alterego == body.alterego
    Then assert response.description == body.description
    Then match response.powers == body.powers
    Given url apiUrl + '/' + response.id
    When method DELETE
    Then status 204

  @id:4 @DeleteExistingCharacter
  Scenario: T-API-HU-0001-CA04 - Eliminar un personaje existente de Marvel
    Given url apiUrl
    * def body =
    """
    {
      "name": "Iron Man4",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    And request body
    When method POST
    Then status 201
    * def createdCharacter = response
    Given url apiUrl + '/' + createdCharacter.id
    When method DELETE
    Then status 204

  @id:5 @GetNotExistingCharacter
  Scenario: T-API-HU-0001-CA05 - Obtener un error al intentar obtener un personaje que no existe
    Given url apiUrl + '/' + 999999
    When method GET
    Then status 404
    Then match response == errorStructure
    Then assert response.error == characterNotFoundErrorMessage

  @id:6 @DeleteNotExistingCharacter
  Scenario: T-API-HU-0001-CA06 - Obtener un error al intentar eliminar un personaje que no existe
    Given url apiUrl + '/' + 999999
    When method DELETE
    Then status 404
    Then match response == errorStructure
    Then assert response.error == characterNotFoundErrorMessage

  @id:7 @ValidateDuplicateCharacterCreation
  Scenario: T-API-HU-0001-CA07 - Obtener un error al intentar crear un personaje que ya existe
    Given url apiUrl
    And request body
    When method POST
    Then status 201
    * def createdCharacter = response
    Given url apiUrl
    And request body
    When method POST
    Then status 400
    Then match response == errorStructure
    Then assert response.error == 'Character name already exists'
    Given url apiUrl + '/' + createdCharacter.id
    When method DELETE
    Then status 204

  @id:8 @ValidateDuplicateCharacterCreation
  Scenario Outline: T-API-HU-0001-CA08 - Obtener un error al intentar crear un personaje sin mandar un campo requerido
    Given url apiUrl
    And body["<field>"] = null
    And request body
    When method POST
    Then status 400
    Then assert response["<field>"] == "<error>"
    Examples:
        | field | error |
        | name |   Name is required     |
        | alterego | Alterego is required |
        | description | Description is required |
    | powers | Powers are required |

  @id:9 @UpdateExistingCharacter
  Scenario: T-API-HU-0001-CA09 - Actualizar un personaje existente de Marvel
    Given url apiUrl
    * def body =
    """
    {
      "name": "Iron Man5",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    And request body
    When method POST
    Then status 201
    * def createdCharacter = response
    Given url apiUrl + '/' + createdCharacter.id
    And body.alterego = "Only Stark"
    And request body
    When method PUT
    Then status 200
    Then match response == itemStructure
    Then assert response.id == createdCharacter.id
    Then assert response.name == createdCharacter.name
    Then assert response.alterego == body.alterego
    Then assert response.description == createdCharacter.description
    Then match response.powers == createdCharacter.powers
    Given url apiUrl + '/' + createdCharacter.id
    When method DELETE
    Then status 204

  @id:10 @UpdateNotExistingCharacter
  Scenario: T-API-HU-0001-CA10 - Obtener un error al intentar actualizar un personaje que no existe
    Given url apiUrl + '/' + 999999
    And request body
    When method PUT
    Then status 404
    Then match response == errorStructure
    Then assert response.error == characterNotFoundErrorMessage