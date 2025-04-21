import 'package:faris/controller/last_tontine_controller.dart';
import 'package:faris/controller/tontine_controller.dart';
import 'package:get/get.dart';
import 'package:faris/controller/tontine_details_controller.dart';
import 'package:faris/data/models/body/membre_body.dart';
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';
import 'package:faris/data/repositories/user_repo.dart';
import 'package:faris/data/core/api_checker.dart';


class ContactController extends GetxController implements GetxService {

  final UserRepo userRepo;
  final FarisTontineRepo tontineRepo;

  ContactController({required this.userRepo, required this.tontineRepo});


  //List<Contact>? contacts;
  List<Membre> _selectedContacts = [];
  List<Membre> _contactList = [];
  bool _contactLoading = false;
  bool _membreLoaded = false;
  bool _membreAdded = false;

  List<Membre> get contactList => _contactList;
  List<Membre> get selectedContacts => _selectedContacts;
  bool get contactLoading => _contactLoading;
  bool get membreLoaded => _membreLoaded;
  bool get membreAdded => _membreAdded;


  searchContact(String numero) async {
    _contactLoading = true;
    update();
    Response response = await userRepo.searchUser(numero);
    if(response.statusCode == 200){
      _contactList = [];
      _contactList.addAll(membresFromJson(response.body['users']));
      _contactLoading = false;
      update();
    }else{
      _contactLoading = false;
      ApiChecker.CheckApi(response);
    }
  }

  Future<ResponseModel> addMembre(MembreBodyList membreBodyList, int tontine) async {
    Response response = await tontineRepo.addMembre(membreBodyList, tontine);
    ResponseModel responseModel;
    if(response.statusCode == 200 || response.statusCode == 201){
      _membreAdded = true;
      responseModel = ResponseModel(true, response.body['message']);
      Get.find<TontineDetailsController>().getTontineMembres(tontine, true);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
    }else{
      responseModel = ResponseModel(false, response.statusText);
      _membreAdded = true;
    }
    update();
    return responseModel;
  }

  getMembres(bool reload, int tontine) async {
    if(reload){
      Response response = await tontineRepo.getTontineMembres(tontine);
      if(response.statusCode == 200){
        _selectedContacts = [];
        _selectedContacts.addAll(membresFromJson(response.body['membres']));
        _selectedContacts.sort((a, b) => a.ordre!.compareTo(b.ordre!));
        _membreLoaded = true;
        update();
      }else{
        ApiChecker.CheckApi(response);
      }
    }
  }

  void addToMemberList(Membre contact, int index){
    /*List<Membre> membres = [];
    membres.addAll(_selectedContacts);
    membres.add(contact);*/
    _selectedContacts.add(contact);
    _contactList = [];
    update();
  }

  void removeToMemberList(Membre contact, int index){
    _selectedContacts.remove(contact);
    update();
  }

  void insertAtIndex(Membre contact, int index){
    _selectedContacts.insert(index, contact);
    update();
  }

  void removeAtIndex(int oldIndex, int newIndex){
    final membre = _selectedContacts.removeAt(oldIndex);
    _selectedContacts.insert(newIndex, membre);
    update();
  }

  void removeToContactList(int index){
    _contactList.removeAt(index);
    update();

  }

  void removeAllMemberList(){
    _selectedContacts.clear();
    _contactList.clear();
    update();
    /*for(int i = 0; i < friendList.length; i++){
      friendList[i].selected = false;
    }*/
  }

  /*getAppUsers(){

    List<User> users =  [
      User(nom: "OUEDRAOGO", prenom: "Abdoulaye", telephone: "+22676022244", selected: false, avatar: 'https://images.unsplash.com/photo-1513152697235-fe74c283646a?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1117&q=80'),
      User(nom: "TIENDREBEOGO", prenom: "Abel", telephone: "+22679365050", selected: false, avatar: 'https://images.unsplash.com/photo-1621856157705-734c22eeab5a?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',),
      User(nom: "LAMIZANA", prenom: "Abraham", telephone: "+22676515702", selected: false, avatar: 'https://images.unsplash.com/photo-1535931737580-a99567967ddc?ixid=MnwxMjA3fDB8MHxzZWFyY2h8NjJ8fHByb2ZpbGUlMjBwaG90b3xlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',),
      User(nom: "SIEL SARL ", prenom: "Alassane", telephone: "+22654542726", selected: false, avatar: 'https://images.unsplash.com/photo-1621352152645-61f4835b081b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTM3fHxwcm9maWxlJTIwcGhvdG98ZW58MHx8MHx8&auto=format&fit=crop&w=600&q=60',),
      User(nom: "", prenom: "Camille", telephone: "+22671334598", selected: false, avatar: 'https://images.unsplash.com/photo-1619714063956-8450bf433d8d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=634&q=80'),
      User(nom: "", prenom: "Christian", telephone: "+22676542765", selected: false),
      User(nom: "", prenom: "Dieudonné", telephone: "+22676200845", selected: false),
      User(nom: "SOMDA", prenom: "Fab", telephone: "+22676672806", selected: false),
      User(nom: "", prenom: "Fitwinnie", telephone: "+22677706991", selected: false),
    ];

    appUsers.value = users;
  }*/

  /*getContacts() async {
    contacts.clear();
    friendList.clear();
    selectedContacts.clear();
    List<User> users = [];
    Iterable<Contact> contactList = await ContactsService.getContacts(withThumbnails: false);
    List<Contact> conts  = contactList.where((contact) => contact.displayName != null && contact.phones?.length != 0).toSet().toList();

    List<Contact> contactFinals  = conts.where((contact) {
      return contact.phones!.elementAt(0).value!.length >= 8;
    }).toList();

    //Récupérer la liste des amies qui ont mon contact et qui sont sur l'application
    appUsers.forEach((user) {
     contactFinals.forEach((contact) {
       String phone = contact.phones!.elementAt(0).value!;
       phone = Common.phoneNumber(phone);
       if(user.telephone == phone){
         users.add(User(nom: user.nom, prenom: user.prenom, telephone: user.telephone, displayName: contact.displayName, email: user.email, selected: false));
       }
     });
    });

    //print("Friends => ${friendList.length}");
    friendList.value = users;
  }*/


  /*Future askContactPermission() async {
    final permissionStatus = await getContactPermission();

    if(permissionStatus == PermissionStatus.granted){
      getContacts();
    }else{
      _handleInvalidPermision(permissionStatus);
    }
  }

  Future<PermissionStatus> getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      PermissionStatus newPermission = await Permission.contacts.request();
      return newPermission;
    }else{
      return permission;
    }
  }

  void _handleInvalidPermision(PermissionStatus permissionStatus){
    if(permissionStatus == PermissionStatus.denied){
      Common.showSnackbar("Permission", "L'accès à la liste des contacts a été réfusée", Colors.red, Colors.white);
    }else if(permissionStatus == PermissionStatus.permanentlyDenied){
      Common.showSnackbar("Permission", "La liste des contacts est indisponible sur ce téléphone", Colors.red, Colors.white);
    }
  }*/
}