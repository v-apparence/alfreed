import 'package:alfreed/alfreed.dart';
import 'main.dart';
import 'model.dart';

class MyPresenter extends Presenter<MyModel, ViewInterface> {
  MyPresenter() : super(state: MyModel()) {
    this.state!.title = "My todo list";
  }

  @override
  Future onInit() async {
    this.state!.todoList = [];
    for (int i = 0; i < 4; i++) {
      this.state!.todoList!.add(new TodoModel("TODO $i", "my todo task $i"));
    }
    this.refreshView();
    super.onInit();
  }

  void addTodo(String s) {
    this
        .state!
        .todoList!
        .add(new TodoModel("TODO ${this.state!.todoList!.length - 1}", s));
  }

  void addTodoWithRefresh(String s) {
    this
        .state!
        .todoList!
        .add(new TodoModel("TODO ${this.state!.todoList!.length - 1}", s));
    refreshView();
  }

  onClickItem(int index) {
    view.showMessage("Item clicked $index");
  }

  void terminate() {
    view.pop();
  }
}
