import 'package:flutter/material.dart';
import '../view_model/anime_list_view_model.dart';
import 'package:animeishi/model/factory/anime_list_factory.dart';

class AnimeListHeader extends StatelessWidget {
  final AnimeListViewModel viewModel;
  final VoidCallback onFetchFromServer;
  final VoidCallback onDeleteSelected;
  final VoidCallback onSaveSelected;

  const AnimeListHeader({
    Key? key,
    required this.viewModel,
    required this.onFetchFromServer,
    required this.onDeleteSelected,
    required this.onSaveSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSortSection(),
            SizedBox(height: 16),
            _buildFetchButton(),
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSortSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF667eea).withOpacity(0.1),
            Color(0xFF764ba2).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF667eea).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sort, color: Color(0xFF667eea), size: 20),
          SizedBox(width: 8),
          Text(
            'ソート順:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: DropdownButton<SortOrder>(
                value: viewModel.sortOrder,
                underline: SizedBox.shrink(),
                isExpanded: true,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
                onChanged: (SortOrder? newValue) {
                  if (newValue != null) {
                    viewModel.setSortOrder(newValue);
                  }
                },
                items: [
                  DropdownMenuItem(value: SortOrder.tid, child: Text('TID順')),
                  DropdownMenuItem(value: SortOrder.year, child: Text('年代順')),
                  DropdownMenuItem(value: SortOrder.name, child: Text('名前順')),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.8),
                  Color(0xFF764ba2).withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: viewModel.toggleSortOrder,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    viewModel.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFetchButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: viewModel.isLoading
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [Color(0xFF48BB78), Color(0xFF38A169)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: viewModel.isLoading
                ? Colors.grey.withOpacity(0.3)
                : Color(0xFF48BB78).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: viewModel.isLoading ? null : onFetchFromServer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (viewModel.isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
              ] else ...[
                Icon(Icons.cloud_download_outlined, color: Colors.white, size: 20),
                SizedBox(width: 12),
              ],
              Text(
                viewModel.isLoading ? '読み込み中...' : 'オンラインから取得',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: viewModel.isLoading
                    ? [Colors.grey.shade300, Colors.grey.shade400]
                    : [Color(0xFFf093fb).withOpacity(0.8), Color(0xFFf5576c).withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: viewModel.isLoading
                      ? Colors.grey.withOpacity(0.3)
                      : Color(0xFFf093fb).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: viewModel.isLoading ? null : onDeleteSelected,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('削除', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: viewModel.isLoading
                    ? [Colors.grey.shade300, Colors.grey.shade400]
                    : [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: viewModel.isLoading
                      ? Colors.grey.withOpacity(0.3)
                      : Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: viewModel.isLoading ? null : onSaveSelected,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('登録', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
