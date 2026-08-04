import 'package:flutter/material.dart';


class CategorySidebar extends StatelessWidget {


  final List<String> categories;

  final int selectedIndex;

  final Function(int) onSelected;



  const CategorySidebar({

    super.key,

    required this.categories,

    required this.selectedIndex,

    required this.onSelected,

  });



  @override
  Widget build(BuildContext context){


    return Container(

      width: 110,

      color: const Color(0xfffff3e6),


      child: ListView.builder(

        padding: const EdgeInsets.only(top:20),

        itemCount: categories.length + 1,


        itemBuilder:(context,index){


          final selected =
              index == selectedIndex;


          final name =
          index == 0
              ? "Featured"
              : categories[index-1];


          return InkWell(

            onTap:(){

              onSelected(index);

            },


            child: Container(

              padding:
              const EdgeInsets.symmetric(
                  vertical:18,
                  horizontal:8
              ),


              color:selected
                  ? Colors.white
                  : Colors.transparent,


              child:Column(

                children:[


                  if(selected)

                    Container(

                      width:5,
                      height:5,

                      margin:
                      const EdgeInsets.only(bottom:6),

                      decoration:
                      const BoxDecoration(

                        color:Colors.orange,

                        shape:BoxShape.circle,

                      ),

                    ),



                  Text(

                    name,

                    textAlign:TextAlign.center,

                    style:TextStyle(

                      fontSize:13,

                      fontWeight:selected
                          ? FontWeight.bold
                          : FontWeight.normal,


                      color:selected
                          ? Colors.orange
                          : Colors.black87,

                    ),

                  )


                ],

              ),

            ),

          );


        },


      ),

    );


  }


}