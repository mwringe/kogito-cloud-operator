@quarkus
Feature: Deploy quarkus service

  Background:
    Given Namespace is created

  Scenario Outline: Deploy drools-quarkus-example service without persistence
    Given Kogito Operator is deployed
    
    When "<installer>" deploy quarkus example service "drools-quarkus-example" with native "<native>"

    Then Kogito application "drools-quarkus-example" has 1 pods running within <minutes> minutes
    And HTTP GET request on service "drools-quarkus-example" with path "persons/all" is successful within 2 minutes
    
    @cr
    Examples: CR Non Native
      | installer | native | minutes |
      | CR        | false  | 10      |

    @cr
    @native
    Examples: CR Native
      | installer | native | minutes |
      | CR        | true   | 20      |

    @smoke
    @cli
    Examples: CLI Non Native
      | installer | native | minutes |
      | CLI       | false  | 10      |

    @cli
    @native
    Examples: CLI Native
      | installer | native | minutes |
      | CLI       | true   | 20      |

#####

  @persistence
  Scenario Outline: Deploy jbpm-quarkus-example service with persistence
    Given Kogito Operator is deployed with Infinispan operator
    And "<installer>" deploy quarkus example service "jbpm-quarkus-example" with native "<native>" and persistence
    And Kogito application "jbpm-quarkus-example" has 1 pods running within <minutes> minutes
    And HTTP GET request on service "jbpm-quarkus-example" with path "orders" is successful within 3 minutes
    And HTTP POST request on service "jbpm-quarkus-example" with path "orders" and body:
      """json
      {
        "approver" : "john", 
        "order" : {
          "orderNumber" : "12345", 
          "shipped" : false
        }
      }
      """
    And HTTP GET request on service "jbpm-quarkus-example" with path "orders" should return an array of size 1 within 1 minutes
    
    When Scale Kogito application "jbpm-quarkus-example" to 0 pods within 2 minutes
    And Scale Kogito application "jbpm-quarkus-example" to 1 pods within 2 minutes
    
    Then HTTP GET request on service "jbpm-quarkus-example" with path "orders" should return an array of size 1 within 2 minutes
    
    @cr
    Examples: CR Non Native
      | installer | native | minutes |
      | CR        | false  | 10      |

    @cr
    @native
    Examples: CR Native
      | installer | native | minutes |
      | CR        | true   | 20      |

    @cli
    Examples: CLI Non Native
      | installer | native | minutes |
      | CLI       | false  | 10      |

    @cli
    @native
    Examples: CLI Native
      | installer | native | minutes |
      | CLI       | true   | 20      |

#####

  # Disabled as long as https://issues.redhat.com/browse/KOGITO-1163 and https://issues.redhat.com/browse/KOGITO-1166 is not solved
  @disabled
  @cr
  @jobsservice
  Scenario Outline: Deploy timer-quarkus-example service with Jobs service
    Given Kogito Operator is deployed
    And "CR" install Kogito Jobs Service with 1 replicas
    And "CR" deploy quarkus example service "timer-quarkus-example" with native "<native>"
    And Kogito application "timer-quarkus-example" has 1 pods running within <minutes> minutes

    When HTTP POST request on service "timer-quarkus-example" is successful within 2 minutes with path "timer" and body:
      """json
      { }
      """

    # Implement retrieving of job information from Jobs service once https://issues.redhat.com/browse/KOGITO-1163 is fixed
    Then Kogito application "timer-quarkus-example" log contains text "Before timer" within 1 minutes
    And Kogito application "timer-quarkus-example" log contains text "After timer" within 1 minutes

    Examples: Non Native
      | native | minutes |
      | false  | 10      |

    # Disabled as long as https://issues.redhat.com/browse/KOGITO-1179 is not solved
    @disabled
    @native
    Examples: Native
      | native | minutes |
      | true   | 20      |
