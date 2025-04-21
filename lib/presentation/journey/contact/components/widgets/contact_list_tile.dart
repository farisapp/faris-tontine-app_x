import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:faris/controller/contact_controller.dart';
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/user_model.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class ContactListTile extends StatelessWidget {
  final Membre contact;
  final int index;
  final bool isSearch;
  final VoidCallback onPress;

  const ContactListTile({Key? key, required this.contact, required this.index, required this.isSearch, required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      leading: Container(
        height: 50,
        width: 53,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 23,
              child: SvgPicture.asset(
                "assets/icons/person.svg",
                color: Colors.white,
                height: 30,
                width: 30,
              ),
              backgroundColor: Colors.blueGrey[200],
            ),
            contact.selected
                ? Positioned(
                    bottom: 4,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: AppColor.kTontinet_primary_light,
                      radius: 11,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      title: Row(
        children: [
          isSearch ? SizedBox.shrink() : Container(
            height: 20,
            width: 20,
            child: Center(child: Text("${index + 1}", style: TextStyle(fontSize: 12, color: Colors.white))),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black
            ),
          ),
          isSearch ? SizedBox.shrink() : SizedBox(width: 5,),
          Text(
            "${contact.displayName}",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Text(
        "${contact.telephone}",
        style: TextStyle(
          fontSize: 13,
        ),
      ),
      trailing: IconButton(
          onPressed: onPress,
          icon: Icon(
              isSearch ? Icons.person_add : Icons.person_remove,
              color: isSearch ? Colors.green : Colors.red,
          ),
      ) /*TextButton(
          onPressed: onPress,
          child: Text(isSearch ? "Ajouter" : "Retirer",
            style: TextStyle(
                color: isSearch ? Colors.green : Colors.red,
                fontSize: 12, fontWeight: FontWeight.bold
            ),
          )
      ),*/
    );
  }
}
