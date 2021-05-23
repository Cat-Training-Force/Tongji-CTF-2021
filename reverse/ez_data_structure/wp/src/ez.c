#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _TreeNode{
    char data;
    struct _TreeNode *left;
    struct _TreeNode *right;
} TreeNode;
// 深度优先算法建图
void gGraph(char *s,size_t len,size_t *cnt,TreeNode*head){
    if(*cnt>=len){
        head->left=NULL;
        head->right=NULL;
        return;
    }
    if(s[*cnt]=='#')head->left=NULL;
    else{
        head->left=malloc(sizeof(TreeNode));
        head->left->data=s[*cnt];
        (*cnt)++;
        gGraph(s,len,cnt,head->left);
    }
    (*cnt)++;
    if(*cnt>=len){
        head->right=NULL;
        return;
    }
    if(s[*cnt]=='#')head->right=NULL;
    else{
        head->right=malloc(sizeof(TreeNode));
        head->right->data=s[*cnt];
        (*cnt)++;
        gGraph(s,len,cnt,head->right);
    }
    return;
}
TreeNode*generateGraph(char *s,size_t len){
    size_t cnt=0;
    if(len==0)return NULL;
    TreeNode*head=malloc(sizeof(TreeNode));
    head->data=s[0];
    cnt=1;
    gGraph(s,len,&cnt,head);
    return head;
}
void firstOrderTraversal(TreeNode *head,char *res,size_t *cnt){
    if(head==NULL)return;
    res[*cnt]=head->data;
    (*cnt)++;
    firstOrderTraversal(head->left,res,cnt);
    firstOrderTraversal(head->right,res,cnt);
}
void middleOrderTraversal(TreeNode *head,char*res,size_t *cnt){
    if(head==NULL)return;
    middleOrderTraversal(head->left,res,cnt);
    res[*cnt]=head->data;
    (*cnt)++;
    middleOrderTraversal(head->right,res,cnt);
}
void check(char *s,size_t len){
    if(len!=33){
        return;
    }
    if(strlen(s)!=33){
        return;
    }
    size_t tn_cnt=0;
    for(size_t i=0;i<len;i++){
        tn_cnt+=(s[i]!='#');
    }
    // flag
    char target[]="2d03fc53456ceeea#30c35fd24ecee6a5";
    // 生成树
    TreeNode *head=generateGraph(s,len);
    char *res=malloc(tn_cnt*2+1);
    size_t cnt=0;
    firstOrderTraversal(head,res,&cnt);
    res[cnt++]='#';
    middleOrderTraversal(head,res,&cnt);
    // printf("%s\n%ld\n%s\n",s,len,res);
    if(!strcmp(res,target)){
        printf("Your input is flag\n");
    }else{
        printf("Oops...flag wrong\n");
    }
}
int main(){
    // char input[]="2d03##fc#53#####4#56ce##ee###a###";
    char input[256];
    scanf("%s",input);
    check(input,strlen(input));
    return 0;
}