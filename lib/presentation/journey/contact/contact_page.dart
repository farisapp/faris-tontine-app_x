import 'package:faris/controller/splash_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/controller/contact_controller.dart';
import 'package:faris/data/models/body/membre_body.dart';
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/presentation/journey/contact/components/widgets/contact_list_tile.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:share_plus/share_plus.dart';

class ContactPage extends StatefulWidget {
  final Tontine tontine;

  const ContactPage({Key? key, required this.tontine}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  ContactController _contactController = Get.find<ContactController>();

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //contactController.askContactPermission();
    _contactController.getMembres(true, widget.tontine.id!);
  }

  /*_openContactForm() async {
    try {
      var contact = await ContactsService.openContactForm();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Membres de l'épargne collective",
              style: TextStyle(
                  color: AppColor.kTontinet_secondary,
                  fontSize: 20,
                  fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800)
                      .fontFamily),
            ),
            GetBuilder<ContactController>(builder: (contactController) {
              return Text(
                contactController.selectedContacts.length > 0
                    ? "${contactController.selectedContacts.length} ${Common.pluralize(contactController.selectedContacts.length, "membre")} ${Common.pluralize(contactController.selectedContacts.length, "ajouté")}"
                    : "Ajouter des membres",
                style: TextStyle(
                  color: AppColor.kTontinet_secondary,
                  fontSize: 13,
                ),
              );
            })
          ],
        ),
        leading: InkWell(
          child: Icon(Icons.arrow_back, color: AppColor.kTontinet_secondary,),
          onTap: (){
            _contactController.removeAllMemberList();
            Get.back();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_secondary),
        actions: [
          PopupMenuButton<String>(
              padding: EdgeInsets.all(0),
              onSelected: (value) {
                print(value);
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: Text("Invité un(e) ami(e)"),
                    value: "invite un ami",
                    onTap: (){
                      Share.share('Bonjour, je vous invites à intégrer un épargne collective dont le code est: << *${widget.tontine.numero}* >>. Pour participer à cette épargne collective, téléchargez gratuitement Faris sur Google Play. https://cutt.ly/D9j9VBy', subject: 'Invitation à épargner!');
                      /*Get.find<SplashController>().getShortLink("https://play.google.com/store/apps/details?id=com.powersofttechnology.faris").then((result) {
                        if(result.isSuccess){

                        }else{
                          showCustomSnackBar(context,"Une erreur s'est produite");
                        }
                      });*/
                    },
                  ),
                  /*PopupMenuItem(
                    child: Text("Contacts"),
                    value: "contacts",
                  ),*/
                  /*PopupMenuItem(
                    child: Text("Actualiser"),
                    value: "actualiser",
                  )*/
                ];
              })
        ],
      ),
        floatingActionButton: GetBuilder<ContactController>(
          builder: (contactController) {
            List<Membre> _membres = contactController.selectedContacts;
            if (_membres.isEmpty) {
              return SizedBox.shrink();
            } else {
              return FloatingActionButton.extended(
                onPressed: () {
                  List<MembreBody> membreBodies = [];
                  int index = 1;
                  for (int i = 0; i < _membres.length; i++) {
                    membreBodies.add(MembreBody(id: _membres[i].id, ordre: index));
                    index++;
                  }
                  contactController
                      .addMembre(MembreBodyList(membreBodies: membreBodies), widget.tontine.id!)
                      .then((result) {
                    if (result.isSuccess) {
                      showCustomSnackBar(context, "Membres ajouté avec succès", isError: false);
                      // Retour automatique après 2 secondes si le widget est toujours monté
                      Future.delayed(Duration(seconds: 2), () {
                        if (mounted) {
                          Get.back();
                        }
                      });
                    } else {
                      showCustomSnackBar(context, result.message);
                    }
                  });
                },
                icon: Icon(Icons.check, color: Colors.white),
                label: Text("Valider", style: TextStyle(color: Colors.white)),
                backgroundColor: AppColor.kTontinet_primary_light,
              );
            }
          },
        ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Numéro de téléphone",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.brown),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 3),
                    ),
                    onChanged: (value) {

                    }
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  if(_searchController.text.isEmpty){

                  }else{
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if (_searchController.text.length < 8 || _searchController.text.length > 8) {
                        showCustomSnackBar(context, "Le numéro de téléphone doit contenir 8 chiffres");
                      }else if (!_searchController.text.trim().isNumericOnly) {
                        showCustomSnackBar(context, 'Le numéro de téléphone ne doit pas contenir des caractères spéciaux');
                      }else{
                        String phone = "226${_searchController.text}";
                        _contactController.searchContact(phone);
                      }

                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.brown,
                  ),
                  child: Center(child: Icon(Icons.send, color: Colors.white,)),
                ),
              )
            ],
          ),
          GetBuilder<ContactController>(builder: (contactController) {
            if(contactController.contactLoading){
              return SizedBox(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: CircularProgressIndicator(),)
              );
            }else if(contactController.contactList != null){
                if(contactController.contactList.isEmpty){
                  return SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text("Aucun utilisateur trouvé", style: TextStyle(fontSize: 12, color: Colors.grey),),)
                  );
                }else{
                  return SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: contactController.contactList.length,
                        itemBuilder: (context, index){
                          return ContactListTile(
                            contact: contactController.contactList[index],
                            index: index,
                            isSearch: true,
                            onPress: (){
                              _searchController.text = "";
                              Membre membre = contactController.selectedContacts.firstWhere((membre) => membre.id == contactController.contactList[index].id, orElse: () => Membre());
                              if(membre.id == null){
                                contactController.addToMemberList(
                                    contactController.contactList[index], index);
                              }else{
                                showCustomSnackBar(context, "Cet utilisateur est déjà membre de votre groupe");
                                contactController.removeToContactList(index);
                              }
                            },
                          );
                        }
                    ),
                  );
                }
            }else{
              return SizedBox.shrink();
            }
          }),

          GetBuilder<ContactController>(builder: (contactController) {
            if(contactController.selectedContacts.isEmpty) {
              return Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_outlined, size: 64, color: Colors.grey,),
                          SizedBox(height: 10,),
                          Text("Vous n'avez pas de membres dans votre épargne", style: TextStyle(color: Colors.grey, fontSize: 13),),
                        ],
                      ),
                    ),
                  )
              );
            }else{
              return Expanded(
                child: ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex)  {
                      final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                      contactController.removeAtIndex(oldIndex, index);
                    },
                    header: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(child: Text("Réorganisez vos membres selon l'ordre de prise", style: TextStyle(fontSize: 20, color: Colors.brown, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),),
                    ),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: contactController.selectedContacts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ContactListTile(
                        key: ValueKey(contactController.selectedContacts[index]),
                        contact: contactController.selectedContacts[index],
                        index: index,
                        isSearch: false,
                        onPress: () {
                          /*if(contactController.selectedContacts.length == 1){

                          }
                          List<MembreBody> membreBodies = [];
                          int index = 1;
                          for(int i=0; i < _membres.length; i++){
                            print(_membres[i].id);
                            MembreBody membreBody = new MembreBody(id: _membres[i].id, ordre: index);
                            membreBodies.add(membreBody);
                            index++;
                          }
                          contactController.addMembre(MembreBodyList(membreBodies: membreBodies), widget.tontine.id!).then((result) {
                            if(result.isSuccess){
                              showCustomSnackBar(context, "Membres ajouté avec succès", isError: false);
                            }else{
                              showCustomSnackBar(context, result.message);
                            }
                          });*/
                          contactController.removeToMemberList(
                              contactController.selectedContacts[index], index);
                        },
                      );
                    }),
              );
            }

          }),
        ],
      )
    );
  }

}
