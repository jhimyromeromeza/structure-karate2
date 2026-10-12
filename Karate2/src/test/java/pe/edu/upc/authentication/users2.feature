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
      | name           | username | email                         |
      | Carlos Ramos   | cramos   | carlos.ramos@upc.edu.pe       |
      | Ana Torres     | atorres  | ana.torres@upc.edu.pe         |
      | Luis Gomez     | lgomez   | luis.gomez@upc.edu.pe         |
      | Maria Silva    | msilva   | maria.silva@upc.edu.pe        |
      | Pedro Morales | pmorales | pedro.morales@upc.edu.pe      |

  # -------------------------------------------------------------
  # 2. PRUEBA CON ESTRUCTURA PARA VALIDACIONES (Payload Invalido)
  # -------------------------------------------------------------
  Scenario: Validar el envio de datos con formato incorrecto
    * table invalidPayload
      | username                 | email                          | phone         |
      | 'usuario_sin_nombre'     | 'correo-invalido-sin-formato' | 'abc-no-numero' |
    Given request invalidPayload[0]
    When method post
    # JSONPlaceholder simula un 201 siempre, pero validamos el contrato del payload
    Then status 201
    And match response !contains { name: '#string' }
    And match response.email == invalidPayload[0].email

  # -------------------------------------------------------------
  # 3. PRUEBA DE ACTUALIZACIÓN COMPLETA (PUT)
  # -------------------------------------------------------------
  Scenario: Actualizar completamente un usuario con PUT
    * def updateData =
      """
      {
        id: 1,
        name: 'Juan Perez Actualizado',
        username: 'jperez_updated',
        email: 'juan.perez.updated@upc.edu.pe',
        address: {
          street: 'Av. Primavera',
          suite: 'Suite 404',
          city: 'Lima',
          zipcode: '15023'
        },
        phone: '999-888-777',
        website: 'upc.edu.pe',
        company: {
          name: 'UPC Tech',
          catchPhrase: 'Innovación educativa',
          bs: 'education tech'
        }
      }
      """
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
    * table patchRows
      | email                     | phone         |
      | 'nuevo.email@upc.edu.pe' | '900-111-222' |
    * def patchData = patchRows[0]
    Given path '1'
    And request patchData
    When method patch
    Then status 200
    And match response.email == patchData.email
    And match response.phone == patchData.phone
    # Verifica que el ID siga siendo el mismo
    And match response.id == 1