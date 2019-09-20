// Class: UnregisteredTrafficController
@isTest
public class UnregisteredTrafficControllerTest {
    static testMethod void unReg(){
        String a = UnregisteredTrafficController.dogetRecordtypeid();
        system.assertNotEquals(a, '');
      } 
}