import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 自定义滚轮日期选择器
///
/// 设计风格：温柔、安静、克制
/// 底部弹出的滚轮选择器，iOS风格但更柔和
class DateWheelPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? title;
  final String? confirmText;
  final String? cancelText;

  const DateWheelPicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title,
    this.confirmText,
    this.cancelText,
  });

  /// 显示日期选择器
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? title,
    String? confirmText,
    String? cancelText,
  }) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder:
          (ctx) => DateWheelPicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            title: title,
            confirmText: confirmText,
            cancelText: cancelText,
          ),
    );
  }

  @override
  State<DateWheelPicker> createState() => _DateWheelPickerState();
}

class _DateWheelPickerState extends State<DateWheelPicker> {
  late DateTime _selectedDate;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  List<int> _years = [];
  List<int> _months = [];
  List<int> _days = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _initializeLists();
    _initializeControllers();
  }

  void _initializeLists() {
    // 年份列表
    _years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (i) => widget.firstDate.year + i,
    );

    // 月份列表
    _months = List.generate(12, (i) => i + 1);

    // 天数列表
    _updateDays();
  }

  void _initializeControllers() {
    final yearIndex = _years.indexOf(_selectedDate.year);
    final monthIndex = _selectedDate.month - 1;
    final dayIndex = _selectedDate.day - 1;

    _yearController = FixedExtentScrollController(
      initialItem: yearIndex >= 0 ? yearIndex : 0,
    );
    _monthController = FixedExtentScrollController(initialItem: monthIndex);
    _dayController = FixedExtentScrollController(initialItem: dayIndex);
  }

  void _updateDays() {
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    _days = List.generate(daysInMonth, (i) => i + 1);
  }

  void _onYearChanged(int index) {
    setState(() {
      final newYear = _years[index];
      _selectedDate = DateTime(
        newYear,
        _selectedDate.month,
        _selectedDate.day.clamp(
          1,
          _getDaysInMonth(newYear, _selectedDate.month),
        ),
      );
      _updateDays();
    });
  }

  void _onMonthChanged(int index) {
    setState(() {
      final newMonth = index + 1;
      _selectedDate = DateTime(
        _selectedDate.year,
        newMonth,
        _selectedDate.day.clamp(
          1,
          _getDaysInMonth(_selectedDate.year, newMonth),
        ),
      );
      _updateDays();
    });
  }

  void _onDayChanged(int index) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        index + 1,
      );
    });
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示条
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.warmGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 取消按钮
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      widget.cancelText ?? '取消',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.warmGray500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  // 标题
                  Text(
                    widget.title ?? '选择日期',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.warmGray800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // 确定按钮
                  GestureDetector(
                    onTap: () => Navigator.pop(context, _selectedDate),
                    child: Text(
                      widget.confirmText ?? '确定',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.warmOrangeDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 分割线
            Container(height: 1, color: AppColors.warmGray200),

            // 滚轮选择器
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  // 年份
                  Expanded(
                    flex: 3,
                    child: _buildWheel(
                      controller: _yearController,
                      items: _years.map((y) => '$y年').toList(),
                      onChanged: _onYearChanged,
                    ),
                  ),

                  // 月份
                  Expanded(
                    flex: 2,
                    child: _buildWheel(
                      controller: _monthController,
                      items: _months.map((m) => '$m月').toList(),
                      onChanged: _onMonthChanged,
                    ),
                  ),

                  // 日期
                  Expanded(
                    flex: 2,
                    child: _buildWheel(
                      controller: _dayController,
                      items: _days.map((d) => '$d日').toList(),
                      onChanged: _onDayChanged,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required List<String> items,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 44,
      diameterRatio: 1.5,
      squeeze: 1.0,
      useMagnifier: true,
      magnification: 1.1,
      selectionOverlay: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.warmGray200, width: 1),
          ),
        ),
      ),
      onSelectedItemChanged: onChanged,
      children:
          items.map((item) {
            return Center(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.warmGray800,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}
