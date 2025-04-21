import 'package:get/get.dart';
import 'package:faris/data/models/bonplan_categorie.dart';




class BonplanCategroieController extends GetxController {

  static BonplanCategroieController to = Get.find();

  RxList<BonplanCategorie> categories = <BonplanCategorie>[].obs;
  RxList<BonplanCategorie> sousCategories = <BonplanCategorie>[].obs;

  RxInt selectedCategorie = 0.obs;

  @override
  void onInit() {
    getCategories();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  getCategories(){
    List<BonplanCategorie> cats = [
      BonplanCategorie(id: "1", nom: "Vêtements", image: "fashion.svg"),
      BonplanCategorie(id: "2", nom: "Beauté", image: "beauty.svg"),
      BonplanCategorie(id: "3", nom: "Electroniques", image: "electronics.svg"),
      BonplanCategorie(id: "4", nom: "Bijoux", image: "bijoux.svg"),
      BonplanCategorie(id: "5", nom: "Chaussures", image: "chaussure.svg"),
      BonplanCategorie(id: "6", nom: "Jouets", image: "jouets.svg"),
      BonplanCategorie(id: "7", nom: "Meubles", image: "meubles.svg"),
      BonplanCategorie(id: "8", nom: "Téléphones", image: "telephones.svg"),
    ];
    categories.value = cats;
    getSousCategories(categories[selectedCategorie.value].id);
  }

  getSousCategories(String? categorie){
    List<BonplanCategorie> cats = [];
    if(categorie == "1") {
      cats = [
        BonplanCategorie(nom: "Costumes",
            image: "https://img3.freepng.fr/dy/4d452c8c599d55063a5c42c981795bc5/L0KzQYm3UsAzN6d1iZH0aYP2gLBuTgN2caUyftH7bXHvPcjsggIua510jNpybnewdMPskCMueJl0jNG2dHXwgL3olPUuPZI8TKMDM3W4coWAWMEvPmc9TqMANUi0RYKAVcU4QGM3S6k8OT7zfri=/kisspng-suit-formal-wear-clothing-dress-photo-template-5a74183e5b4781.6686155815175578223739.png",
            color: "0xFFf4d4ff"),
        BonplanCategorie(nom: "Robes",
            image: "https://img3.freepng.fr/dy/1056e6f28cac38a01f9af98bb9e60fa6/L0KzQYm3VsE2N5d0R91yc4Pzfri0lBVlbJpzf59tcnX2g37pkvllbV5ohNH9aHnxd377kvFrbaQyTdQ7NEG0dbTqUsE5OGIzSKsBMkG8QIa4VcI6OGo1TaY5N0m4PsH1h5==/kisspng-wedding-dress-bride-clothing-trajes-5b2411ecc21801.096219051529090540795.png",
            color: "0xFFcbcbff"),
        BonplanCategorie(nom: "Pantalons",
            image: "https://img3.freepng.fr/dy/2638170b868dd3d88579aa6199f36b6c/L0KzQYm3V8E3N6ZuR91yc4Pzfri0iPVibKFth9Ducz3rdbLrkBV1NZJ6fNt4LXTkfrTsTfhmaZV1gNH3ZYOwRbO7g8FjbmM2UaoEMUaxSYG7UcM5QWk2TaU6N0G3RYW9UcA1Pl91htk=/kisspng-headphones-headset-audio-dance-headphones-5b4c1bf2198916.9041389815317145461046.png",
            color: "0xFFffc2be"),
        BonplanCategorie(nom: "Chemises",
            image: "https://consumer-img.huawei.com/content/dam/huawei-cbg-site/common/mkt/pdp/tablets/mediapad-t5/img/pic_s1_bg.png",
            color: "0xFFdff5ff"),
        BonplanCategorie(nom: "Robes",
            image: "https://img3.freepng.fr/dy/ea2a71f55901169bab28907149b86900/L0KzQYm3VsA6N6ZmfZH0aYP2gLBuTfVtbZR5ittsYXywc7LpjPUudJpsgOZ3aX7qPcb6gr1ubpoyiOR4Z4LkfX7okQBtbV46eqNrOEK3c4LoVBQ6Ol82TKQ7OEm2QIK8Usg2Omo5UKY6MEi4PsH1h5==/kisspng-electrical-cable-lightning-usb-mfi-program-apple-5b1b824c1a7d92.1422893015285294841085.png",
            color: "0xFFe8dfff"),
        BonplanCategorie(nom: "T-shirts",
            image: "https://img3.freepng.fr/dy/23abf8ab522853c87f870fc92f42f56d/L0KzQYm3VsEzN6ZxiZH0aYP2gLBuTfxmbF51itt3dHX1Pb3okBVzNaF3gdD9aX7qPbX8kPxmgF51itt3dHnxd37wjvsua5J3Rdt2cILsfbL1lPUuPZM3SKZtM0i6QoOAVMMvP2I3SKk5NUG0RYOBWMQ0PWg7TKgCNj7zfri=/kisspng-led-printer-laser-printing-duplex-printing-ink-car-imprimante-5b204d38722743.7120705115288435764676.png",
            color: "0xFFefdfc9"),
        BonplanCategorie(nom: "Pagnes",
            image: "https://img3.freepng.fr/dy/35e625625b9d42275193f6467a594e4b/L0KzQYm3VcI6N5hmh5H0aYP2gLBuTfFxeJ1qRelqdHPrPcTskvlme143RdN5cHzoPcjolPNpNaRqittucz20PbPsjPtqdl46eqJtZXG2dIPpUMJkP181SqI5NUG2Q4K8Usc3O2k6UKs6N0a1PsH1h5==/kisspng-apple-watch-series-2-apple-watch-series-1-belkin-5b0dea3d2b02c7.0200513315276385891762.png",
            color: "0xFFe8dfff"),
        //BonplanCategorie(nom: "Machines à laver", image: "https://img3.freepng.fr/dy/b73f54c9bb5990df983fc350a2d4da0e/L0KzQYm3V8I5N6R0jJH0aYP2gLBuTgdie5luhtk2bXHmeLr1hgMubZ1qeAZ7b3z4iH7slBMyO2Y1ReJ7aXPoPb7ogBhqdpYyeZ91YYbogn68gsVkOGU5SdNrN3S2SHA8WMMyPGg7UKMAM0K6RYi3Vcc4OGM5RuJ3Zx==/kisspng-washing-machines-electrolux-ewc1350-price-machine-a-laver-5b5c0441ab7d38.5831476815327570577024.png", color: "0xFFbef58d"),
        //BonplanCategorie(nom: "Gazinières", image: "https://www.pngfind.com/pngs/b/222-2227170_laptop-top-view-png.png", color: "0xFFa7f1b6"),
        BonplanCategorie(nom: "Tissus",
            image: "https://img3.freepng.fr/dy/20a4f12a3a1375b8ad48f905722f4797/L0KzQYq3WcE4N6VugZH9cnHxg8HokvVvfF54hdN1bD3kgMHzifFva5YygNH2ZT3kgMHzifFva5Yyg9t9Y3jofn7okQBtcZJze9c2bT24dIm4WPE5aZI3edQ8Nj62SIO6WcQ1OGI6TqoCN0C5SYm9VsY0NqFzf3==/transparent-small-appliance-home-appliance-kitchen-appliance-m-5d818a8aa2ab36.3823944015687706986663.png",
            color: "0xFFffe9a8"),
      ];
    }else if(categorie == "3"){
      cats = [
        BonplanCategorie(nom: "Ordinateur portable / PC ", image: "https://www.pngfind.com/pngs/b/222-2227170_laptop-top-view-png.png", color: "0xFFf4d4ff"),
        BonplanCategorie(nom: "Télévisions", image: "https://www.tcl.com/content/dam/tcl-dam/product/p-series/p5/site/homepage/products-P5-global.png", color: "0xFFcbcbff"),
        BonplanCategorie(nom: "Casques Audio", image: "https://img3.freepng.fr/dy/2638170b868dd3d88579aa6199f36b6c/L0KzQYm3V8E3N6ZuR91yc4Pzfri0iPVibKFth9Ducz3rdbLrkBV1NZJ6fNt4LXTkfrTsTfhmaZV1gNH3ZYOwRbO7g8FjbmM2UaoEMUaxSYG7UcM5QWk2TaU6N0G3RYW9UcA1Pl91htk=/kisspng-headphones-headset-audio-dance-headphones-5b4c1bf2198916.9041389815317145461046.png", color: "0xFFffc2be"),
        BonplanCategorie(nom: "Tablettes", image: "https://consumer-img.huawei.com/content/dam/huawei-cbg-site/common/mkt/pdp/tablets/mediapad-t5/img/pic_s1_bg.png", color: "0xFFdff5ff"),
        BonplanCategorie(nom: "Accessoires téléphone", image: "https://img3.freepng.fr/dy/ea2a71f55901169bab28907149b86900/L0KzQYm3VsA6N6ZmfZH0aYP2gLBuTfVtbZR5ittsYXywc7LpjPUudJpsgOZ3aX7qPcb6gr1ubpoyiOR4Z4LkfX7okQBtbV46eqNrOEK3c4LoVBQ6Ol82TKQ7OEm2QIK8Usg2Omo5UKY6MEi4PsH1h5==/kisspng-electrical-cable-lightning-usb-mfi-program-apple-5b1b824c1a7d92.1422893015285294841085.png", color: "0xFFe8dfff"),
        BonplanCategorie(nom: "Imprimantes", image: "https://img3.freepng.fr/dy/23abf8ab522853c87f870fc92f42f56d/L0KzQYm3VsEzN6ZxiZH0aYP2gLBuTfxmbF51itt3dHX1Pb3okBVzNaF3gdD9aX7qPbX8kPxmgF51itt3dHnxd37wjvsua5J3Rdt2cILsfbL1lPUuPZM3SKZtM0i6QoOAVMMvP2I3SKk5NUG0RYOBWMQ0PWg7TKgCNj7zfri=/kisspng-led-printer-laser-printing-duplex-printing-ink-car-imprimante-5b204d38722743.7120705115288435764676.png", color: "0xFFefdfc9"),
        BonplanCategorie(nom: "Montres connectées", image: "https://img3.freepng.fr/dy/35e625625b9d42275193f6467a594e4b/L0KzQYm3VcI6N5hmh5H0aYP2gLBuTfFxeJ1qRelqdHPrPcTskvlme143RdN5cHzoPcjolPNpNaRqittucz20PbPsjPtqdl46eqJtZXG2dIPpUMJkP181SqI5NUG2Q4K8Usc3O2k6UKs6N0a1PsH1h5==/kisspng-apple-watch-series-2-apple-watch-series-1-belkin-5b0dea3d2b02c7.0200513315276385891762.png", color: "0xFFe8dfff"),
        //BonplanCategorie(nom: "Machines à laver", image: "https://img3.freepng.fr/dy/b73f54c9bb5990df983fc350a2d4da0e/L0KzQYm3V8I5N6R0jJH0aYP2gLBuTgdie5luhtk2bXHmeLr1hgMubZ1qeAZ7b3z4iH7slBMyO2Y1ReJ7aXPoPb7ogBhqdpYyeZ91YYbogn68gsVkOGU5SdNrN3S2SHA8WMMyPGg7UKMAM0K6RYi3Vcc4OGM5RuJ3Zx==/kisspng-washing-machines-electrolux-ewc1350-price-machine-a-laver-5b5c0441ab7d38.5831476815327570577024.png", color: "0xFFbef58d"),
        //BonplanCategorie(nom: "Gazinières", image: "https://www.pngfind.com/pngs/b/222-2227170_laptop-top-view-png.png", color: "0xFFa7f1b6"),
        BonplanCategorie(nom: "Electroménagers", image: "https://img3.freepng.fr/dy/20a4f12a3a1375b8ad48f905722f4797/L0KzQYq3WcE4N6VugZH9cnHxg8HokvVvfF54hdN1bD3kgMHzifFva5YygNH2ZT3kgMHzifFva5Yyg9t9Y3jofn7okQBtcZJze9c2bT24dIm4WPE5aZI3edQ8Nj62SIO6WcQ1OGI6TqoCN0C5SYm9VsY0NqFzf3==/transparent-small-appliance-home-appliance-kitchen-appliance-m-5d818a8aa2ab36.3823944015687706986663.png", color: "0xFFffe9a8"),
      ];
    }
    sousCategories.value = cats;
  }

  changeCategorie(int index){
    selectedCategorie.value = index;
    getSousCategories(categories[index].id!);
    update();
  }
}