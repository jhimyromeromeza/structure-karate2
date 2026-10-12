Feature: Pruebas automatizadas sobre la API de Usuarios (/users)

  Background:
    * url 'https://jsonplaceholder.typicode.com'
    * path 'users'

  # -------------------------------------------------------------
  # 1. DATA-DRIVEN TESTING (Carga masiva de 5 usuarios)
  # -------------------------------------------------------------
  Scenario Outline: Crear usuario mediante Data-Driven Testing - <name>
    Given request { name: '<name>', username: '<username>', email: '<email>' }
    When method post
    Then status 201
    And match response.id == '#number'
    And match response.name == '<name>'
    And match response.username == '<username>'
    And match response.email == '<email>'

    Examples:
      | read('classpath:pe/edu/upc/authentication/data/users-batch.json') |

  # -------------------------------------------------------------
  # 2. PRUEBA CON ESTRUCTURA PARA VALIDACIONES (Payload Invalido)
  # -------------------------------------------------------------
  Scenario: Validar el envio de datos con formato incorrecto
    * def invalidPayload = read('classpath:pe/edu/upc/authentication/data/invalid-user.json')
    Given request invalidPayload
    When method post
    # JSONPlaceholder simula un 201 siempre, pero validamos el contrato del payload
    Then status 201
    And match response !contains { name: '#string' }
    And match response.email == invalidPayload.email

  # -------------------------------------------------------------
  # 3. PRUEBA DE ACTUALIZACIÓN COMPLETA (PUT)
  # -------------------------------------------------------------
  Scenario: Actualizar completamente un usuario con PUT
    * def updateData = read('classpath:pe/edu/upc/authentication/data/update-user.json')
    Given path '1'
    And request updateData
    When method put
    Then status 200
    And match response.name == updateData.name
    And match response.address.city == updateData.address.city
    And match response.company.name == updateData.company.name

  # -------------------------------------------------------------
  # 4. PRUEBA DE ACTUALIZACIÓN PARCIAL (PATCH)
  # -------------------------------------------------------------
  Scenario: Actualizar parcialmente solo el email y telefono de un usuario con PATCH
    * def patchData = { email: 'nuevo.email@upc.edu.pe', phone: '900-111-222' }
    Given path '1'
    And request patchData
    When method patch
    Then status 200
    And match response.email == patchData.email
    And match response.phone == patchData.phone
    # Verifica que el ID siga siendo el mismo
    And match response.id == 1