import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/user_model.dart';


class AvatarWidget extends StatelessWidget {
  final Membre user;

  const AvatarWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 23,
                  child: SvgPicture.asset("assets/icons/person.svg", color: Colors.white, height: 30, width: 30,),
                  backgroundColor: Colors.blueGrey[200],
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 11,
                      child: Icon(Icons.clear, color: Colors.white, size: 13,),
                    )
                )
              ],
            ),
            SizedBox(height: 2,),
            Text(
              "${user.displayName!.split(" ")[0]}",
              style: TextStyle(
                fontSize: 12
              ),
            )
          ],
        ),
    );
  }
}
